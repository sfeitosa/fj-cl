-- Arbitrary class table for testing Featherweight Java interpreter.
-- Author: Samuel da Silva Feitosa
-- Date: 03/2018
--------------------------------------------------------------------
module CT where
import FJParser
import FJUtils
import FJInterpreter
import FJTypeChecker
import Data.Map

{-
interface Supplier {
  Object get();
}
-}

intSupplier = Interface "Supplier" [] 
                [(Sign (Type "Object") "get" [])] -- Abstract methods
--                (Sign (Type "Object") "getY" [])] -- Abstract methods
                [] -- Default methods

{-
interface Function {
  Object apply(Object a);
} 
-}

intFunction = Interface "Function" [] 
                [(Sign (Type "Object") "apply" -- Abstract methods
                  [(Type "Object","a")])]
                [] -- Default methods

{-
interface BiFunction {
  Object apply(Object a, Object b);
}
-}

intBiFunction = Interface "BiFunction" []
                  [(Sign (Type "Object") "apply" -- Abstract methods
                    [(Type "Object", "a"), (Type "Object", "b")])]
                  [] -- Default methods

{-
class A extends Object {
  Supplier obj;
  A(Object obj) {
    super();
    this.obj = obj;
  }
}
-}

classA = Class "A" "Object" [] -- Base class, derived class and interfaces
           [(Type "Supplier", "obj")] -- Attributes
           (Constr "A" [(Type "Supplier", "obj")] [] [("obj", "obj")]) -- Constructor
           [] -- Methods

{-
class B extends Object {
  B() {
    super();
  }
  Object exec(Supplier s) {
    return s.get();
  }
}
-}

classB = Class "B" "Object" [] -- Base and derived class
           [] -- Attributes
           (Constr "B" [] [] []) -- Constructor
           [(Method (Sign (Type "Object") "exec" [(Type "Supplier", "s")]) (MethodInvk (Var "s") "get" []))] -- Methods

{-
class C extends Object {
  A a;
  B b;
  C(A a, B b) {
    super();
    this.a = a;
    this.b = b;
  }
  A getA() {
    return this.a;
  }
  Object getAData() {
    return this.a.getA();
  }
  Object getBData() {
    return this.b.b;
  }
}
-}

{- 
classC = Class "C" "Object" -- Base and derived class
           [(Type "A", "a"), -- Attributes
            (Type "B", "b")] 
           (Constr "C" [(Type "A", "a"),(Type "B", "b")] [] [("a","a"), ("b","b")]) -- Constructor
           [(Method (Type "A") "getA" [] (FieldAccess (Var "this") "a")), -- Methods
            (Method (Type "Object") "getAData" [] (MethodInvk (FieldAccess (Var "this") "a") "getA" [])),
            (Method (Type "Object") "getBData" [] (FieldAccess (FieldAccess (Var "this") "b") "b"))] 
-}

{-
class D extends Object {
  A a;
  B b;
  D(A a, B b) {
    super();
    this.a = a;
    this.b = b;
  }
  D setAB(Object a, Object b) {
    return new D(new A(a), this.b.setB(b));
  }
}
-}

{-
classD = Class "D" "Object" -- Base and derived class
           [(Type "A", "a"), -- Attributes
            (Type "B", "b")] 
           (Constr "D" [(Type "A", "a"),(Type "B", "b")] [] [("a","a"), ("b","b")]) -- Constructor
           [(Method (Type "D") "setAB" [(Type "Object", "a"),(Type "Object", "b")] (CreateObject "D" [(CreateObject "A" [(Var "a")]),(MethodInvk (FieldAccess (Var "this") "b") "setB" [(Var "b")])]))] 
-}

{-
class E extends Object {
  Object a;
  Object b;
  E(Object a, Object b) {
    super();
    this.a = a;
    this.b = b;
  }
  Object getA() {
    return this.a;
  }
  Object getB() {
    return this.b;
  }
}
-}

{-
classE = Class "E" "Object" -- Base and derived class
           [(Type "Object", "a"),(Type "Object", "b")] -- Attributes
           (Constr "A" [(Type "Object", "a"),(Type "Object", "b")] [] [("a", "a"),("b", "b")]) -- Constructor
           [(Method (Type "Object") "getA" [] (FieldAccess (Var "this") "a")), -- Methods
           (Method (Type "Object") "getB" [] (FieldAccess (Var "this") "b"))] 
-}

--classtable = Data.Map.fromList [("A", classA), ("B", classB), ("C", classC), ("D", classD), ("E", classE)]

classtable = fromList [("Supplier", TInterface intSupplier), ("Function", TInterface intFunction), ("BiFunction", TInterface intBiFunction), ("A", TClass classA), ("B", TClass classB)]
