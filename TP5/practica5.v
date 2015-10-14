Section Ejercicio1.

Inductive list (A : Set) : Set :=
  | nil : list A
  | cons : A -> list A -> list A.

Inductive LE : nat -> nat -> Prop := 
  | Le_O : forall n : nat, LE 0 n 
  | Le_S : forall n m : nat, LE n m -> LE (S n) (S 
m).

Inductive Mem (A : Set) (a : A) : list A -> Prop :=
  | here : forall x : list A, Mem A a (cons A a x) 
  | there : forall x : list A, Mem A a x ->  
forall b : A, Mem A a (cons A b x).

(* 1.1 *)
Theorem not_sn_le_o: forall n:nat, ~ LE (S n) O.
Proof.
  unfold not.
  intros.
  inversion H.
Qed.

(* 1.2 *)
Theorem nil_empty (A:Set): forall a:A, ~ Mem A a (nil A).
Proof.
  unfold not.
  intros.
  inversion H.
Qed.

(* 1.3 *)
Theorem e13: ~ LE 4 3.
Proof.
  unfold not.
  intro.
  repeat (inversion_clear H; inversion_clear H0).
Qed.

(* 1.4 *)
Theorem e14: forall n:nat, ~ LE (S n) n.
Proof.
  unfold not.
  intros.
  induction n;
  inversion H;
  exact (IHn H2).
Qed.

(* 1.5 *)
Theorem e15: forall n m p:nat,
  LE n m /\ LE m p -> LE n p.
Proof.
  induction n.
  intros.
    constructor.

    intros.
    destruct H.
    inversion H0.
    rewrite <- H1 in H.
    apply not_sn_le_o in H.
    contradiction.

    constructor.
    rewrite <- H2 in H.
    inversion H.
    apply (IHn n0 m0).
    split; trivial.
Qed.

(* 5.6 *)

End Ejercicio1.

Section Ejercicio3.

Variable A : Set.
Parameter equal : A -> A -> bool.

Axiom equal1 : forall x y : A, equal x y = true -> 
x = y.
Axiom equal2 : forall x : A, equal x x <> false.

Inductive List : Set :=
  | nullL : List
  | consL : A -> List -> List.

Inductive MemL (a : A) : List -> Prop :=
  | hereL : forall x : List, MemL a (consL a x)
  | thereL : forall x : List, MemL a x -> forall b
: A, MemL a (consL b x).

(* 3.1 *)
Inductive isSet : List -> Prop :=
  | isSetNil : isSet nullL
  | isSetCons : forall (x : A) (l : List),
    ~MemL x l /\ isSet l -> isSet (consL x l).

(* 3.2 *)
Fixpoint deleteAll (x : A) (xs : List) : List :=
  match xs with
    | nullL => xs
    | consL y ys =>
      if equal x y
      then deleteAll x ys
      else consL y (deleteAll x ys)
  end.

(* 3.3 *)
Lemma DeleteAllNotMember : forall (l : List) (x : A),
   ~ MemL x (deleteAll x l).
Proof.
  unfold not.
  intros.
  induction l.
    inversion H.

    inversion H.
    simpl in H.
    remember (equal x a) as y.
    destruct y.
      exact (IHl H).

      injection H1.
      intros.
      symmetry in Heqy.
      rewrite H2 in Heqy.
      apply equal2 in Heqy.
      trivial.

    simpl in H.
    remember (equal x a) as y.
    destruct y.
      exact (IHl H).

      injection H0.
      intros.
      rewrite <- H2 in IHl.
      exact (IHl H1).
Qed.

(* 3.4 *)
Fixpoint delete (x : A) (xs : List) : List :=
  match xs with
    nullL => nullL
    | consL y ys =>
      if equal x y then ys
      else consL y (delete x ys)
  end.

Lemma setCons : forall (l : List) (x : A),
  isSet (consL x l) -> isSet l.
Proof.
  intros.
  induction l.
    apply isSetNil.

    inversion H.
    destruct H1.
    trivial.
Qed.

(* 3.5 *)
Lemma DeleteNotMember : forall (l : List) (x : A), 
isSet l -> ~ MemL x (delete x l).
Proof.
  unfold not.
  intros.
  induction l.
    inversion H0.

    simpl in H0.
    remember (equal x a) as y.
    destruct y.
    symmetry in Heqy.
    apply equal1 in Heqy.
    inversion H.
    destruct H2.
    rewrite <- Heqy in H2.
    contradiction.

    inversion H0.
    symmetry in Heqy.
    rewrite H2 in Heqy.
    apply equal2 in Heqy.
    trivial.
    apply setCons in H.
    apply IHl; trivial.
Qed.

End Ejercicio3.

Section Ejercicio4.

Variable A : Set.

Inductive AB : Set :=
   nullAB : AB
   | consAB : A -> AB -> AB -> AB.

(* 4.a *)
Inductive Pertenece : A -> AB -> Prop :=
  pertNullAB : forall (x : A) (t1 t2 : AB),
    Pertenece x (consAB x t1 t2)
  | pertConsABLeft : forall (x y: A) (t1 t2 : AB),
    Pertenece x t1 -> Pertenece x (consAB y t1 t2)
  | pertConsABRight : forall (x y: A) (t1 t2 : AB),
    Pertenece x t2 -> Pertenece x (consAB y t1 t2).

(* 4.b *)
Parameter eqGen: A -> A -> bool.

Fixpoint Borrar (ab : AB) (x : A) : AB :=
  match ab with
    nullAB => nullAB
    | consAB y lt rt =>
      if eqGen x y then nullAB
      else consAB y (Borrar lt x) (Borrar rt x)
  end.

(* 4.c *)
Axiom eqGen1 : forall x : A, ~ (eqGen x x) = false. 
(*(negb (eqGen x x)) = false.*)

Lemma e4cAux : forall (t1 t2 : AB) (a b : A),
  ~ (Pertenece a t1) /\
  ~ (Pertenece a t2) /\
  eqGen a b = false ->
  Pertenece a (consAB b t1 t2) -> False.
Proof.
  unfold not.
  intros.
  destruct H as [H1 [H2 H3]].
  inversion H0.
    rewrite H5 in H3.
    apply eqGen1 in H3.
    trivial.

    exact (H1 H5).

    exact (H2 H5).
Qed.

Lemma BorrarNoPertenece: forall (x : AB) (a : A),
  ~(Pertenece a (Borrar x a)).
Proof.
  unfold not.
  intros.
  induction x.
    inversion H.

    simpl in H.
    remember (eqGen a a0) as y.
    destruct y.
      inversion H.

      symmetry in Heqy.
      apply (e4cAux (Borrar x1 a) (Borrar x2 a) a a0);
        [ unfold not; split; [ | split]
        | ]; trivial.
Qed. 

(* 4.d *)
Inductive SinRepetidos : AB -> Prop :=
  nullABNoRep : SinRepetidos nullAB
  | consABNoRep : forall (a : A) (t1 t2 : AB),
    SinRepetidos t1 /\
    SinRepetidos t2 /\
    (forall (x : A),
      Pertenece x t1 -> ~ Pertenece x t2) /\
    (forall (x : A),
      Pertenece x t2 -> ~ Pertenece x t1) /\
    ~ Pertenece a t1 /\
    ~ Pertenece a t2 ->
    SinRepetidos (consAB a t1 t2).

End Ejercicio4.

Section Ejercicio5.

(* 5.1 *)
Definition Var : Set := nat.

Inductive BoolExpr : Set :=
  BoolVar : Var -> BoolExpr
  | Bool : bool -> BoolExpr
  | Or : BoolExpr -> BoolExpr -> BoolExpr
  | Not : BoolExpr -> BoolExpr.

(* 5.2 *)
Definition Valor : Set := bool.

Definition Memoria : Set := Var -> Valor.

Definition lookup : Memoria -> Var -> Valor :=
  fun f v => f v.

Inductive BEval : BoolExpr -> Memoria -> bool -> Prop :=
  | evar : forall (v : Var) (m : Memoria),
      BEval (BoolVar v) m (lookup m v)
  | eboolt : forall (m : Memoria),
      BEval (Bool true) m true
  | eboolf : forall (m : Memoria),
      BEval (Bool false) m false
  | eorl : forall (e1 e2 : BoolExpr) (m : Memoria),
      BEval e1 m true -> BEval (Or e1 e2) m true
  | eorr : forall (e1 e2 : BoolExpr) (m : Memoria),
      BEval e2 m true -> BEval (Or e1 e2) m true
  | eorrl : forall (e1 e2 : BoolExpr) (m : Memoria),
      BEval e1 m false /\ BEval e2 m false ->
        BEval (Or e1 e2) m false
  | enott : forall (e : BoolExpr) (m : Memoria),
      BEval e m true -> BEval (Not e) m false
  | enotf : forall (e : BoolExpr) (m : Memoria),
      BEval e m false -> BEval (Not e) m true
  .

(* 5.4 *)
Fixpoint beval (m : Memoria) (b : BoolExpr) : Valor :=
  match b with
    | BoolVar v => lookup m v
    | Bool b => b
    | Or e1 e2 => orb (beval m e1) (beval m e2)
    | Not e => negb (beval m e)
  end.

(* 5.5 *)
Lemma e55 : forall (m : Memoria) (e : BoolExpr),
  BEval e m (beval m e).
Proof.
  intros.
  induction e.
    simpl.
    apply evar.

    simpl.
    destruct b.
      apply eboolt.

      apply eboolf.

    simpl.
    destruct (beval m e1).
      simpl.
      apply (eorl e1 e2 m) in IHe1.
      trivial.

      simpl.
      destruct (beval m e2).
        apply (eorr e1 e2 m) in IHe2.
        trivial.

        apply (eorrl e1 e2 m).
        split; trivial.

    simpl.
    destruct (beval m e).
      simpl.
      apply enott.
      trivial.

      simpl.
      apply enotf.
      trivial.

Qed.

(* 5.3 *)
Lemma e53a : forall (m : Memoria),
  ~ (BEval (Bool true) m false).
Proof.
  unfold not.
  intros.
  inversion H.
Qed.

Lemma e53b :
  forall (m : Memoria) (e1 e2 : BoolExpr) (w : bool),
    BEval e1 m false /\
    BEval e2 m w ->
    BEval (Or e1 e2) m w.
Proof.
  intros.
  destruct w.
    apply eorr.
    apply H.

    apply eorrl.
    trivial.
Qed.

(*
Lemma e53cAux :
  forall (m : Memoria) (e : BoolExpr),
    BEval e m true -> ~ (BEval e m false).
Proof.
  unfold not.
  intros.
  inversion H.
    inversion H0.
      rewrite <- H3 in H1.
      injection H1.
      intro.
      rewrite <- H6 in H7.
      rewrite H7 in H4.
      discriminate H4.

      rewrite <- H3 in H1.
      discriminate H1.

      rewrite <- H5 in H1.
      discriminate H1.

      rewrite <- H5 in H1.
      discriminate H1.

      rewrite <- H1 in H0.
      apply e53a in H0.
      trivial.

      rewrite <- H2 in H0.
      apply e53b in H0.
Qed.
*)

(*
Lemma determinismo :
  forall (m : Memoria) (e : BoolExpr) (w1 w2 : bool),
    BEval e m w1 /\ BEval e m w2 ->
    BEval e m w1 = BEval e m w2.
Proof.
  intros.
  destruct H.
  induction e.
  destruct w1;
  destruct w2; trivial.
    inversion H.
    inversion H0.
    trivial.

    inversion H.
    inversion H0.
    trivial.

  destruct w1;
  destruct w2; trivial.
    inversion H.
    inversion H0.
    rewrite H4.
    rewrite H2.
    trivial.

    inversion H.
    inversion H0.
    rewrite H4.
    rewrite H2.
    trivial.

  destruct w1.
    destruct w2.
      trivial.

      

  destruct w1;
  destruct w2; trivial;
    inversion H;
    inversion H0.
      destruct H8.
      assert (BEval e1 m true = BEval e1 m false).
      exact (IHe1 H4 H8).

Qed.

Lemma e53c :
  forall (m : Memoria) (e : BoolExpr) (w1 w2 : bool),
    BEval e m w1 /\ BEval e m w2 -> w1 = w2.
Proof.
  intros.
  destruct H.
  destruct w1;
  destruct w2.
    trivial.

    induction e.
      inversion H.
      
    

  intros.
  destruct H.
  induction H; trivial;
    inversion H0; trivial.

    inversion H0.
    rewrite H4.
    trivial.

    rewrite <- H4 in H9.
    trivial.

    destruct H5.
    rewrite H4 in H5.
    apply IHBEval in H5.
    rewrite <- H5 in H9.
    symmetry.
    trivial.

    destruct H5.
    rewrite H4 in H6.
    rewrite H4.
    exact (IHBEval H6).

    destruct H4.
    inversion H0.
      destruct H4.
      exact (IHBEval H5).



  destruct H;
  destruct w1;
  destruct w2;
  destruct H0; inversion H; trivial.
  
Qed.

Lemma e53d :
  forall (m : Memoria) (e1 e2 : BoolExpr),
    BEval e1 m true -> ~ BEval (Not (Or e1 e2)) m true.
Proof.
  unfold not.
  intros.
  apply (eorl e1 e2) in H.
  apply enott in H.
Qed.
*)
End Ejercicio5.

Section Ejercicio6.

(* 6.1 *)

Inductive Instr : Set :=
  | Skip : Instr
  | Assign : Var -> BoolExpr -> Instr
  | IfThenElse : BoolExpr -> Instr -> Instr -> Instr
  | While : BoolExpr -> Instr -> Instr
  | Begin : LInstr -> Instr
  with
  LInstr : Set :=
  | Fin : LInstr
  | Seq : Instr -> LInstr -> LInstr
  .

(* 6.2 *)
Infix ";" := Seq (at level 80, right associativity).

Variable v1 v2 : Var.

Definition PP : Instr :=
  Begin (
    Assign v1 (Bool true);
    Assign v2 (Not (BoolVar v1));
    Fin
  ).

Variable aux : Var.

Definition swap : Instr :=
  Begin (
    Assign aux (BoolVar v1);
    Assign v1 (BoolVar v2);
    Assign v2 (BoolVar aux);
    Fin
  ).

(* 6.3 *)
Fixpoint eqnat (n1 n2 : nat) : bool :=
  match n1, n2 with
    | 0, 0 => true
    | (S n), (S m) => eqnat n m
    | _, _ => false
  end.

Definition update : Memoria -> Var -> Valor -> Memoria :=
  fun m v w =>
    fun (var : Var) =>
      if eqnat v var then w else lookup m var
  .

End Ejercicio6.

Section Ejercicio7.



End Ejercicio7.