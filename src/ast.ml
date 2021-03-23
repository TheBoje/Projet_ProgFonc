(* ================================================== *)
(* ===================== AST.ML ===================== *)
(*
  Ce module a été créé par le groupe d'étudiants suivant :
  - Vincent Commin
  - Louis Leenart
  Le contenu de ce module a été fait d'apres le sujet de
  projet de Programmation Fonctionnelle suivant les 
  directives du sujet.
*)
(* ================================================== *)


(* ================================================== *)
(* ================== IMPORTATIONS ================== *)
(* ================================================== *)

open Expression_scanner;;

(* ================================================== *)
(* ====================== TYPE ====================== *)
(* ================================================== *)

type operator = 
  | Plus
  | Minus 
  | Mult
  | Div
;;


type tree = 
  | Var    of char 
  | Cst    of int
  | Unary  of tree
  | Binary of operator * tree * tree
;;


(* ================================================== *)
(* ================ UTILITAIRES AST ================= *)
(* ================================================== *)


let operator_to_string(op : operator) : string =
  match op with
  | Plus  -> "+"
  | Minus -> "-"
  | Mult  -> "*"
  | Div   -> "/"
;;


(* On met la division prioritaire par rapport à la multiplication à cause de sa non-assossiativité *)
let get_order_operator(ope : operator) : int =
  match ope with
  | Plus  -> 1
  | Minus -> 1
  | Mult  -> 2
  | Div   -> 3
;;


(* Si l'opérateur 1 est prioritaire par rapport à l'opérateur 2, alors on retourne vrai *)
let operator_priority(ope1, ope2 : operator * operator) : bool =
  (get_order_operator(ope1) > get_order_operator(ope2))
;;


(* empile un enracinement binaire sur une pile d'arbre *)
let token_to_binary_operator_stack(op, stack : operator * tree list) : tree list =
  match stack with
  | [] -> failwith "list is empty"
  | v1::v2::tail -> (Binary(op, v2, v1))::tail
  | _  -> failwith "Error input: postfix expression needed" 
;;


(* 
  Détermine si l'arbre contient uniquement des constantes
*)
let rec is_cst_tree(input : tree) : bool =
  match input with
  | Var(_) -> false
  | Cst(_) -> true
  | Unary(tree) -> is_cst_tree(tree)
  | Binary(_, left, right) -> is_cst_tree(left) && is_cst_tree(right)
;;


(* On regarde si l'opérateur "op" est prioritaire sur l'opérateur de la branche "branch" *)
let need_parenthesis(op, branch : operator * tree) : bool =
  match branch with
  | Binary(branchOp, _, _) -> operator_priority(op, branchOp)
  | _ -> false
;;


(* ================================================== *)
(* =========== OPÉRATIONS PRINCIPALES AST =========== *)
(* ================================================== *)

(* récupère une liste de token pour retourner un arbre de syntaxe non-simplifé *)
let parse (input : token list) : tree =
  let rec aux(tk_list, stack : token list * tree list) : tree =
    match tk_list with
    | [] -> failwith "No end point for the expression"
    | hd::tail ->
      match hd with
      | End           -> List.hd(stack)
      | Number(num)   -> aux(tail, Cst(num)::stack)
      | Variable(var) -> aux(tail, Var(var)::stack)
      (* Opérateur unaire -> la tête de liste est une constante ou variable donc on la remplace par un opérateur unaire sur la tête de la liste *)
      | Minus         -> aux(tail, Unary(List.hd(stack))::(List.tl(stack))) 
      | Add           -> aux(tail, token_to_binary_operator_stack(Plus,  stack))
      | Subtract      -> aux(tail, token_to_binary_operator_stack(Minus, stack))
      | Multiply      -> aux(tail, token_to_binary_operator_stack(Mult,  stack))
      | Divide        -> aux(tail, token_to_binary_operator_stack(Div,   stack))
  in
  aux(input, [])
;;

(*
  let exp = parse(string_to_token_list("13 2 5 *  1 x / - +;"));;
*)


(* 
  Évaluation de l'arbre Pour évaluer l'arbre, on applique l'opérateur qui est à
  la racine aux deux sous arbres jusqu'à arriver sur une constante. Si on
  rencontre une variable, on ne peut pas l'évaluer, on retourne alors une
  exception. 
*)
let rec eval(input : tree) : int =
  match input with
  | Binary(Plus,  left, right)   -> eval(left) + eval(right) (* Opérateurs binaires *)
  | Binary(Minus, left, right)   -> eval(left) - eval(right)
  | Binary(Mult,  left, right)   -> eval(left) * eval(right)
  | Binary(Div,   left, right)   -> eval(left) / eval(right)
  | Cst(value)  -> value
  | Unary(tree) -> (-1)*eval(tree)
  | Var _       -> failwith "Eval: Cannot evaluate variable"
;;


(*
  Simplification de l'arbre
  On applique différents patterns de simplification basique. On note que si
  l'arbre (ou un sous arbre) ne contient que des constantes, alors on l'évalue.
  Cette simplification ne supporte pas les opérations avancées comme par exemple
  x + y - x -> y.
*)
let rec simplify (input : tree) : tree = 
  if is_cst_tree(input) (* Si l'arbre ne contient pas de variable, on l'évalue*)
  then Cst(eval(input))
  else (                (* Sinon, on applique les différents patterns de simplification *)
    match input with
    | Binary(Mult, left,  Cst 1)  -> simplify(left)   (* x * 1 -> x *)
    | Binary(Mult, Cst 1, right)  -> simplify(right)  (* 1 * x -> x *)
    | Binary(Plus, left, Cst 0)   -> simplify(left)   (* x + 0 -> x *)
    | Binary(Plus, Cst 0, right)  -> simplify(right)  (* 0 + x -> x *)
    | Binary(Mult, left, Cst 0)   -> Cst 0            (* x * 0 -> 0 *)
    | Binary(Mult, Cst 0, right)  -> Cst 0            (* 0 * x -> 0 *)
    | Binary(Minus, left, right)     when left = right -> Cst 0  (* x - x -> 0 *)
    | Binary(Div, left, right)       when left = right -> Cst 1  (* x / x -> 1 *)
    | Unary(tree)                 -> Unary(simplify(tree))    
    | Binary(ope, left, right)    -> Binary(ope, simplify(left), simplify(right)) (* Aucun des patternes de simplification n'est trouvé, on tente de simplifier les sous arbres *)
    | _ -> input  (* Cas de Cst et Var *)
  )
;; 

(* 
  let exp = parse(string_to_token_list("x 3 + 5 7 + + 3 4 * 1 3 + / /;"));;
  simplify(exp);;
*)


(* ================================================== *)
(* ================== AFFICHAGE AST ================= *)
(* ================================================== *)


(* 
  Affichage de l'expression.
  Avec un parcours infix de l'arbre, on affiche chaque noeud. L'affichage ou non
  des parenthèses est déterminé par la priorité de l'opérateur utilisé par
  rapport à ses fils (s'il est prioritaire, alors il faut afficher le fils entre
  parenthèses).
*)
let print(input : tree) : unit =
  let rec aux(input : tree) : string =
    match input with
    | Var(value)                -> Char.escaped value
    | Cst(value)                -> string_of_int(value)
    | Unary(tree)               -> "-" ^ aux(tree)
    | Binary(ope, left, right)  ->
      match (need_parenthesis(ope, left), need_parenthesis(ope, right)) with
      | (true, true)    -> "(" ^ aux(left) ^ ")" ^ operator_to_string(ope) ^ "(" ^ aux(right) ^ ")"
      | (true, false)   -> "(" ^ aux(left) ^ ")" ^ operator_to_string(ope) ^       aux(right)
      | (false, true)   ->       aux(left) ^       operator_to_string(ope) ^ "(" ^ aux(right) ^ ")"
      | (false, false)  ->       aux(left) ^       operator_to_string(ope) ^       aux(right)
  in
  print_string(aux(input))
;;



(*
  print(exp);;
  print(simplify(exp));;
*)

(* ================================================== *)
(* =============== RÉCUPERATION INPUT =============== *)
(* ================================================== *)

(* Récupération de l'input en tant qu'argument *)
let () =
  let exp = parse(input_to_token_list()) in
  Printf.printf("Expression: ");
  print(exp);
  Printf.printf("\nAprès simplification: ");
  print(simplify(exp));
  Printf.printf("\n");