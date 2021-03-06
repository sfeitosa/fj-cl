-- Haskell interpreter for FJ + Closures
-- Author: Samuel da Silva Feitosa
-- Date: 02/2018
----------------------------------------
module FJInterpreter where
import FJParser
import FJUtils
import Data.Maybe
import Data.List

-- Function: eval'
-- Objective: Evaluate an expression.
-- Params: Class table, Expression.
-- Returns: An expression after processing one reduction step.
--------------------------------------------------------------
eval' :: CT -> Expr -> Maybe Expr
eval' ct (CreateObject c p) = -- RC-New-Arg
  let p' = Data.List.map (\x -> case (eval' ct x) of Just x' -> x') p
    in Just (CreateObject c p')
eval' ct (FieldAccess e f) = 
  if (isValue ct e) then -- R-Field
    case e of 
      (CreateObject c p) ->
        case (fields ct c) of
          Just flds -> 
            case (Data.List.findIndex (\(tp,nm) -> f == nm) flds) of
              Just idx -> Just (lambdaMark (p !! idx) (fst (flds !! idx)))
      _ -> Nothing -- Not an object instance
  else -- RC-Field
    case (eval' ct e) of 
      Just e' -> Just (FieldAccess e' f) 
      _ -> Nothing
eval' ct (MethodInvk e m p) =
  if (isValue ct e) then
    if (Data.List.all (isValue ct) p) then
      case e of 
        (CreateObject c cp) -> -- R-Invk
          case (mbody ct m c) of
            Just (fpn, e') -> 
              case (mtype ct m c) of
                Just (fpt, r) -> 
                  let p' = Data.List.map (\(expr,tp) -> lambdaMark expr tp) 
                                         (zip p fpt)
                    in subst (fpn ++ ["this"]) (p' ++ [e]) (lambdaMark e' r)
                _ -> Nothing -- No method type
            _ -> Nothing -- No method body
        (Cast i (Closure cp exp)) -> 
          case (mtype ct m i) of
            Just (fpt, r) -> 
              case (mbody ct m i) of 
                Just (fpn, e') -> -- R-Default
                  let p' = Data.List.map (\(expr,tp) -> lambdaMark expr tp)
                                         (zip p fpt)
                    in subst fpn p' (lambdaMark e' r) 
                _ -> let p' = Data.List.map -- R-Closure
                                (\(expr,tp) -> lambdaMark expr tp)
                                (zip p fpt)
                       in subst (snd (unzip cp)) p' (lambdaMark exp r)
            _ -> Nothing -- No method type
        _ -> Nothing      
    else 
      -- RC-Invk-Arg
      let p' = Data.List.map (\x -> case (eval' ct x) of Just x' -> x') p 
        in Just (MethodInvk e m p')
  else -- RC-Invk-Recv
    case (eval' ct e) of 
      Just e' -> Just (MethodInvk e' m p)
      _ -> Nothing
eval' ct cc@(Cast t e) = 
  if (isValue ct e) then 
    case e of 
      obj@(CreateObject c' p) -> 
        if (subtyping ct c' t) then -- R-Cast
          Just obj
        else
          Nothing
      int@(Cast i (Closure cp e')) -> 
        if (subtyping ct i t) then -- R-Cast-Closure
          Just int
        else 
          Nothing                                    
      _ -> Just cc -- annotated closure is a value
  else -- RC-Cast
    case (eval' ct e) of
      Just e' -> Just (Cast t e')
      _ -> Nothing 
eval' ct cl@(Closure _ _) = Just cl
eval' _ _ = Nothing


-- Function: eval
-- Objective: Evaluate an expression recursively.
-- Params: Class table, Expression.
-- Returns: A value after all the reduction steps.
--------------------------------------------------
eval :: CT -> Expr -> Expr
eval ct e = if (isValue ct e) then
              e
            else
              maybe e (eval ct) (eval' ct e)


-- Function: subst
-- Objective: Replace actual parameters in method body expression. 
-- Params: List of formal parameters names, List of actual parameters,
-- Method body expression.
-- Returns: A new changed expression.
-------------------------------------------
subst :: [String] -> [Expr] -> Expr -> Maybe Expr
subst p v (Var x) = case (Data.List.elemIndex x p) of 
                      Just idx -> Just (v !! idx)
                      _ -> Nothing
subst p v (FieldAccess e f) = case (subst p v e) of
                                Just e' -> Just (FieldAccess e' f)
                                _ -> Nothing
subst p v (MethodInvk e n ap) = 
  let ap' = Data.List.map (\x -> case (subst p v x) of Just x' -> x') ap in
    case (subst p v e) of 
      Just e' -> Just (MethodInvk e' n ap')
      _ -> Nothing
subst p v (CreateObject c ap) = 
  let ap' = Data.List.map (\x -> case (subst p v x) of Just x' -> x') ap in
    Just (CreateObject c ap')
subst p v (Cast c e) = case (subst p v e) of 
                         Just e' -> Just (Cast c e')
                         _ -> Nothing
subst p v cl@(Closure cp e) = Just cl -- Do nothing

