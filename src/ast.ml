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
      | Subtract     -> aux(tail, token_to_binary_operator_stack(Minus, stack))
      | Multiply      -> aux(tail, token_to_binary_operator_stack(Mult, stack))
      | Divide        -> aux(tail, token_to_binary_operator_stack(Div, stack))
  in
  aux(input, [])
;;

parse(string_to_token_list("13 2 5 *  1 0 / - +;"));;

let simplify (input : tree) : tree = 
  (* TODO *)
;;

let print (input : tree) : unit =
  (* TODO *)
;;
