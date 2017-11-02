(****************************************************************)
(*                                                              *)
(* Math4ti2.m is a package that allows calling functionality    *)
(* of the package 4ti2 (http://www.4ti2.de) from within         *)
(* Mathematica                                                  *)
(*                                                              *)
(* Copyright (C) 2017, Ralf Hemmecke <ralf@hemmecke.org>        *)
(* Copyright (C) 2017, Silviu Radu <sradu@risc.jku.at>          *)
(*                                                              *)
(****************************************************************)

BeginPackage["math4ti2`"]

zsolve::usage = "If we are given a linear system as given in the 4ti2 manual, namely sys={x - y <= 2, -3 x + y <= 1, x + y >= 1, y >= 0}, then simply calling zsolve[sys] will return a triple (list) with the inhomogeneous and the homogeneous solutions and the list of variables that correspond to the solution sets.

zsolve can also be called with 4 arguments like zsolve[A, r, b, s]. The above example would then be entered as A={{1,-1},{-3,1},{1,1}}; r={LessEqual,LessEqual,GreaterEqual}; b={2,1,1}; s={0,1}. Also r={-1,-1,1} or r={\"<\",\"<\", \">\") would be accepted.";

Begin["`Private`"]

(* You must set this variable to point to the directory of executables of 4ti2 *)
bindir="/home/hemmecke/software/4ti2/bin";
zsolvecmd = bindir <> "/zsolve";

(* A sign condition looks like "variable >= 0", so there shouldn't be exactly one
   variable on the lefthand side and 0 on the righthand side.
*)
signCondition[x_] := (Length[Variables[First[x]]] == 1) && (Part[x,2] === 0);

zsolve[sys_List] := Module[
    {vars, s, c, b, A, r},
    (* Extract the variables of the system *)
    vars = Union[Sequence @@ Map[Variables[First[#]]&, sys]];
    (* Remove positivity/negativity conditions *)
    s = Select[sys, !signCondition[#]&];
    (* Replace the relation symbols by Equal signs, then extract the coefficients *)
    c = Normal[CoefficientArrays[Equal @@@ s, vars]];
    b = - First[c];
    A = First[Rest[c]];
    (* Translate relation signs into -1 (for <=), +1 for (>=) and 0 (for ==). *)
    r = Map[Head,s];
    (* Extract positivity/negativity conditions *)
    s = Select[sys, signCondition[#]&];
    If[s=!={}, s = First[Part[Normal[CoefficientArrays[Equal @@@ s, vars]],2]]];
    Append[zsolve[A, r, b, s],vars]
];

(* We assume that sys is given in a form like
   sys={x - y <= 2, -3 x + y <= 1, x + y >= 1, y >= 0}
   From that we extract the lefthand side, then extract the variables
   (ordered by Mathematica), and eventually extract the coefficient
   matrix.
   There is no error handling.
*)

deleteFile[basename_, ext_] := Module[
    {filename}
    ,
    filename = StringJoin[basename, ".", ext];
    If[FileExistsQ[filename], DeleteFile[filename]];
];

readFile[basename_, ext_] := Module[
    {filename}
    ,
    filename = StringJoin[basename, ".", ext];
    If[!FileExistsQ[filename], Return[{}]];
    Rest[ReadList[filename, Number, RecordLists -> True]]
];

zsolve[A_List, r_List, b_List, s_List] := Module[
    {basename, l, result},
    basename = StringJoin["4ti2-",ToString[$SessionID]];
    writeMatrix[A,   basename, "mat"];
    writeMatrix[{b}, basename, "rhs"];
    writeMatrix[{s}, basename, "sign"];
    l = r/.{-1       -> "<", 1           -> ">", 0    -> "=",
            LessEqual-> "<", GreaterEqual-> ">", Equal-> "="};
    writeMatrix[{l}, basename, "rel"];
    RunProcess[{zsolvecmd, basename}];
    result = {
        readFile[basename, "zinhom"],
        readFile[basename, "zhom"],
        readFile[basename, "zfree"]
    };
    (* Now we clean up the temporary files *)
    Scan[(deleteFile[basename,#])&,
         {"mat", "rhs", "sign", "rel", "zinhom", "zhom"}];

    (* return *)
    result
];

(* If m is a list of lists, then it is a list of row vectors.
   If m is just a list, it is a column vector.
   Do not write anything if mat is an empty list.
*)

writeMatrix[mat_, basename_, ext_] := Module[
    {filename, rows, cols},
    filename = StringJoin[basename, ".", ext];
    rows = Length[mat];
    If[rows==0, Return[]];
    cols=Length[First[mat]];
    If[cols==0, Return[]];
    Export[filename, Join[{{rows, cols}}, mat], "Table"]
];

End[]
EndPackage[]
