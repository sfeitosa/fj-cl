-- Haskell parser for FJ + Closures
-- Author: Samuel da Silva Feitosa
-- Date: 03/2018
-----------------------------------
module FJParser where
import Data.Map

-- FJ + Closures syntactic constructors
---------------------------------------
data T = TClass Class
       | TInterface Interface
       deriving (Show, Eq)

-- class C extends D implements I_ { T_ f_; K M_ }
data Class = Class String String [String] [(Type,String)] Constr [Method]
              deriving (Show, Eq)

-- Interface I extends I_ { S_ default M_ }
data Interface = Interface String [String] [Sign] [Method]
               deriving (Show, Eq)

-- C(T_ f_) { super(f_); this.f_.f_; }
data Constr = Constr String [(Type,String)] [String] [(String,String)]
            deriving (Show, Eq)

-- T m(T_ x_)
data Sign = Sign Type String [(Type,String)]
          deriving (Show, Eq)

-- S { return e; }
data Method = Method Sign Expr
            deriving (Show, Eq)

data Expr = Var String                               -- Variable
          | FieldAccess Expr String                  -- Field Access
          | MethodInvk Expr String [Expr]            -- Method Invocation
          | CreateObject String [Expr]               -- Object Instantiation
          | Cast String Expr                         -- Cast
          | Closure [(Type,String)] Expr             -- Closure
          deriving (Show, Eq)

-- FJ + Closures nominal typing
------------------------------
data Type = Type String
          deriving (Show, Eq)

-- FJ + Closures auxiliary definitions
-------------------------------------
type Env = Map String Type
type CT = Map String T

