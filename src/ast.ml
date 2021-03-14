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

let exp = parse(string_to_token_list("13 2 5 *  1 x / - +;"));;

let rec eval(input : tree) : int =
  match input with
  | Binary(Plus, left, right) -> eval(left) + eval(right)
  | Binary(Minus, left, right) -> eval(left) - eval(right)
  | Binary(Mult, left, right) -> eval(left) * eval(right)
  | Binary(Div, left, right) -> eval(left) / eval(right)
  | Cst(value) -> value
  | Unary(tree) -> (-1)*eval(tree)
;;

let rec are_same_tree(tree1, tree2 : tree * tree) : bool = 
  match (tree1, tree2) with 
  | Var(v1), Var(v2) -> (v1 = v2)
  | Cst(v1), Cst(v2) -> (v1 = v2)
  | Unary(tree1), Unary(tree2) -> are_same_tree(tree1, tree2)
  | Binary(ope1, left1, right1), Binary(ope2, left2, right2) -> (ope1 = ope2) && are_same_tree(left1, left2) && are_same_tree(right1, right2)
  | _ -> false
;;

let rec is_cst_tree(input : tree) : bool =
  match input with
  | Var(_) -> false
  | Cst(_) -> true
  | Unary(tree) -> is_cst_tree(tree)
  | Binary(_, left, right) -> is_cst_tree(left) && is_cst_tree(right)
;;

let rec simplify (input : tree) : tree = 
  if (is_cst_tree(input))
  then (Cst(eval(input)))
  else (
    match input with
    | Binary(Mult, left,  Cst 1)  -> simplify(left) (* x * 1 -> x *)
    | Binary(Mult, Cst 1, right)  -> simplify(right) (* 1 * x -> x *)
    | Binary(Plus, left, Cst 0)   -> simplify(left) (* x + 0 -> x *)
    | Binary(Plus, Cst 0, right)  -> simplify(right) (* 0 + x -> x *)
    | Binary(Mult, left, Cst 0)   -> Cst 0 (* x * 0 -> 0 *)
    | Binary(Mult, Cst 0, right)  -> Cst 0 (* 0 * x -> 0 *)
    | Binary(Minus, left, right) when are_same_tree(left, right) -> Cst 0(* x - x -> 0 *)
    | Binary(Div, left, right) when are_same_tree(left, right) -> Cst 1 (* x / x -> 1 *)
    | Unary(tree)                 -> Unary(simplify(tree))
    | Binary(_, Cst _, Cst _)     -> Cst(eval(input))
    | Binary(ope, left, right)      -> Binary(ope, simplify(left), simplify(right))
    | _ -> input
  )
;; 

let exp = parse(string_to_token_list("x 3 + 5 7 + + 3 4 * 1 3 + / /;"));;
simplify(exp);;

let print (input : tree) : unit =
  let rec aux(input : tree) : string =
    match input with
    | Var(value) -> String.make 1 value
    | Cst(value) -> string_of_int(value)
    | Unary(tree) -> aux(tree)
    | Binary(ope, left, right) -> 
      match ope with  
        | Plus -> String.concat "" [aux(left); "+"; aux(right)]
        | Minus -> String.concat "" [aux(left); "-"; aux(right)]
        | Mult -> String.concat "" ["("; aux(left); "*"; aux(right); ")"]
        | Div -> String.concat "" ["("; aux(left); ")"; "/"; "("; aux(right); ")"]
  in
  print_string(aux(input))
;;


print(exp);;
print(simplify(exp));;