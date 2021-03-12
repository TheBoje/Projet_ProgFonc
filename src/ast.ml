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

(*string_to_token_list("1 2 +");;*)

let parse (input : token list) : tree =
  (* TODO *)
;;

let simplify (input : tree) : tree = 
  (* TODO *)
;;

let print (input : tree) : unit =
  (* TODO *)
;;