(****************************************************************)
(*                                                              *)
(* Math4ti2.m is a package that allows calling functionality    *)
(* of the package 4ti2 (http://www.4ti2.de) from within         *)
(* Mathematica                                                  *)
(*                                                              *)
(* Copyright (C) 2017, 2018, Ralf Hemmecke <ralf@hemmecke.org>  *)
(* Copyright (C) 2017, Silviu Radu <sradu@risc.jku.at>          *)
(*                                                              *)
(****************************************************************)

(*****************************************************************
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*****************************************************************)

BeginPackage["math4ti2`"]

zsolve::usage = "If we are given a linear system as given in the 4ti2 manual, namely sys={x - y <= 2, -3 x + y <= 1, x + y >= 1, y >= 0}, then simply calling zsolve[sys] will return a quadrupl (list) with the inhomogeneous, the homogeneous solutions, the free solutions, and the list of variables that correspond to the solution sets.

zsolve[sys] returns the same as zsolve[sys, vars] where vars are the variables appearing in sys in an unspecified order.

zsolve[sys, vars] where vars must be the variables appearing in sys, is the same as zsolve[sys] only that the order of the variables is specified for the output via the vars parameter.

zsolve can be called with 3 arguments like zsolve[A, r, b]. The above example would then be entered as A={{1,-1},{-3,1},{1,1},{0,1}}; r={LessEqual,LessEqual,GreaterEqual,GreaterEqual}; b={2,1,1,0}.

zsolve can also be called with 4 arguments like zsolve[A, r, b, s]. The above example would then be entered as A={{1,-1},{-3,1},{1,1}}; r={LessEqual,LessEqual,GreaterEqual}; b={2,1,1}; s={0,1}. Also r={-1,-1,1} or r={\"<\",\"<\", \">\") would be accepted.

The 3 output matrices correspond to the files with extension '.zinhom', '.zhom', and '.zfree' as described in the 4ti2 manual at http://www.4ti2.de/.";

Begin["`Private`"]

(* Set this variable to point to the directory of executables of 4ti2 *)
zsolvecmd = "/usr/bin/4ti2-zsolve"; (* location debian package 4ti2 *)

copyright[line_, lines___] := Module[
    {txt = line <> StringJoin[Map[("\n"<>#)&,{lines}]]},
    If[$Notebooks,
        CellPrint[Cell[txt, "Text",
            FontColor -> RGBColor[0, 0, 0],
            CellFrame -> 0.5,
            Background -> RGBColor[0.796887, 0.789075, 0.871107],
            ShowAutoSpellCheck -> False (* Needed from MMA11 on *)
        ]],
        Print[txt]
    ]];

copyright[
    "math4ti2: Mathematica interface to 4ti2 (http://www.4ti2.de/)",
    "Copyright (C) 2017, Ralf Hemmecke <ralf@hemmecke.org>",
    "Copyright (C) 2017, Silviu Radu <sradu@risc.jku.at>"
];

zsolve[sys_List] := Module[
    {vars},
    (* Extract the variables of the system *)
    vars = Union[Sequence @@ Map[Variables[First[#]]&, sys]];
    zsolve[sys, vars]
];

zsolve[sys_List, vars_] := Module[
    {c, b, A, r},
    (* Replace the relation symbols by Equal signs, then extract the coefficients *)
    c = Normal[CoefficientArrays[Equal @@@ sys, vars]];
    b = - First[c];
    A = First[Rest[c]];
    (* Translate relation signs into -1 (for <=), +1 for (>=) and 0 (for ==). *)
    r = Map[Head,sys];
    Append[zsolve[A, r, b], vars]
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

zsolve[A_List, r_List, b_List] := zsolve[A, r, b, {}];

zsolve[A_List, r_List, b_List, s_List] := Module[
    {basename, l, result},
    basename = StringJoin["4ti2-",ToString[$SessionID]];
    writeMatrix[A,   basename, "mat"];
    writeMatrix[{b}, basename, "rhs"];
    If[s =!= {}, writeMatrix[{s}, basename, "sign"]];
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
         {"mat", "rhs", "sign", "rel", "zinhom", "zhom", "zfree"}];

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
