#directory "../data";;
#load "expression_scanner.cmo";;

open Expression_scanner;;

type operator = 
  | Plus
  | Minus 
  | Mult
  | Div
;;
type tree = 
  | Var of char 
  | Cst of int
  | Unary of tree
  | Binary of operator * tree * tree
;;

(*
- Récupération de l'input -> parsing to token list (module expression_scanner)
- Transformation de token list -> ast (parse)
- Simplification de l'ast (simplify)
- Affichage de l'ast en expression (print)


Autre :
- Déterminer si une liste de token est bien un mot de Lukasiewicz
- Vérifier que chaque expression se termine par un ';' (indicateur de fin de ligne - token 'End')
- Pas de traitement des erreurs
- Utilisation depuis la console (donc compilé ou semi-compilé?)

Opérations de simplification à implémenter :
- 1 * x -> x
- x * 1 -> x
- 0 + x -> x
- x + 0 -> x
- 0 * x -> 0
- x * 0 -> 0
- x - x -> 0
- x / x -> 1
Note : x + y - x -> y n'est pas demandé comme opération de simplification

*)



let token_to_binary_operator_stack(op, stack : operator * tree list) : tree list =
  match stack with
  | [] -> failwith "list is empty"
  | v1::v2::tail -> (Binary(op, v2, v1))::tail
;;

let parse (input : token list) : tree =
  let rec aux(tk_list, stack : token list * tree list) : tree =
    match tk_list with
    | [] -> failwith "No end point for the expression"
    | hd::tail ->
      match hd with
      | End           -> List.hd(stack)
      | Number(num)   -> aux(tail, Cst(num)::stack)
      | Variable(var) -> aux(tail, Var(var)::stack)
      | Minus         -> aux(tail, Unary(List.hd(stack))::(List.tl(stack))) (* Opérateur unaire -> la tête de liste est une constante ou variable donc on la remplace par un opérateur unaire sur la tête de la liste *)
      | Add           -> aux(tail, token_to_binary_operator_stack(Plus, stack))
      | Subtract      -> aux(tail, token_to_binary_operator_stack(Minus, stack))
      | Multiply      -> aux(tail, token_to_binary_operator_stack(Mult, stack))
      | Divide        -> aux(tail, token_to_binary_operator_stack(Div, stack))
  in
  aux(input, [])
;;

parse(string_to_token_list("13 2 5 *  1 0 / - +;"));;

let rec eval(input : tree) : int =
  match input with
  | Binary(Plus, left, right) -> eval(left) + eval(right)
  | Binary(Minus, left, right) -> eval(left) - eval(right)
  | Binary(Mult, left, right) -> eval(left) * eval(right)
  | Binary(Div, left, right) -> eval(left) / eval(right)
  | Cst(value) -> value
  | Unary(tree) -> eval(tree)
;;

let rec are_same_tree(tree1, tree2 : tree * tree) : bool = 
  match (tree1, tree2) with 
  | Var(v1), Var(v2) -> (v1 = v2)
  | Cst(v1), Cst(v2) -> (v1 = v2)
  | Unary(tree1), Unary(tree2) -> are_same_tree(tree1, tree2)
  | Binary(ope1, left1, right1), Binary(ope2, left2, right2) -> (ope1 = ope2) && are_same_tree(left1, left2) && are_same_tree(right1, right2)
  | _ -> false
;;

let rec simplify (input : tree) : tree = 
  match input with
  | Binary(Mult, left,  Cst 1)  -> simplify(left) (* x * 1 -> x *)
  | Binary(Mult, Cst 1, right)  -> simplify(right) (* 1 * x -> x *)
  | Binary(Plus, left, Cst 0)   -> simplify(left) (* x + 0 -> x *)
  | Binary(Plus, Cst 0, right)  -> simplify(right) (* 0 + x -> x *)
  | Binary(Mult, left, Cst 0)   -> Cst 0 (* x * 0 -> 0 *)
  | Binary(Mult, Cst 0, right)  -> Cst 0 (* 0 * x -> 0 *)
  | Binary(Minus, left, right)  -> (* x - x -> 0 *)
      if (are_same_tree(left, right))
      then (Cst 0)
      else input
  | Binary(Div, left, right)    -> (* x / x -> 1 *)
      if (are_same_tree(left, right))
      then (Cst 1)
      else input
  | Unary(tree)                 -> Unary(simplify(tree))
  | Binary(_, Cst _, Cst _)     -> Cst(eval(input))
  | _ -> input
;;

let exp = parse(string_to_token_list("x x -;"));;
let exp_x1 = parse(string_to_token_list("x;"));;
let exp_x2 = parse(string_to_token_list("x;"));;
are_same_tree(exp_x1, exp_x2);;
simplify(exp);;

let print (input : tree) : unit =
  (* TODO *)
;;
