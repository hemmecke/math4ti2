
ZSolveRunPath = "/home/sradu/4ti2/4ti2-1.6.7/src/zsolve/zsolve"

MakeRel[li_]  := Module[{r, cols, tmp},
  r = {1 -> "> ", 0 -> "= ", -1 -> "< "};
  cols = Length [li];
  tmp = OpenWrite["system.rel"];
  WriteString[tmp, "1 ", ToString[cols], "\n", StringJoin[li /. r]];
  Close[tmp];
  ];

MakeMat[mat_] := Module[{rows, cols, data},
  rows = Length[mat];
  cols = Length[First[mat]];
  data = Join[{{rows, cols}}, mat];
  Export["system.mat", data, "Table"];
  ];

NumberToString[n_] := { StringJoin[ToString[n], " "]};

MakeRhs[li_]  := Module[{r, cols, tmp},
  r = {n -> ToString[n]};
  cols = Length [li];
  tmp = OpenWrite["system.rhs"];
  WriteString[tmp, "1 ", ToString[cols], "\n",
   StringJoin[Map[NumberToString, li]]];
  Close[tmp];
  ];

MakeSign[li_]  := Module[{r, cols, tmp},
  r = {n -> ToString[n]};
  cols = Length [li];
  tmp = OpenWrite["system.sign"];
  WriteString[tmp, "1 ", ToString[cols], "\n",
   StringJoin[Map[NumberToString, li]]];
  Close[tmp];
  ];

ZSolve[mat_, rel_, rhs_, sign_] := Module[{r, r2, m, m2},
  MakeMat[mat];
  MakeRel[rel];
  MakeRhs[rhs];
  MakeSign[sign];
  RunProcess[{ZSolveRunPath, "system"}];
  r = ReadList["system.zinhom", Number, RecordLists -> True];
  First[r];
  m = Rest[r];
  r2 = ReadList["system.zhom", Number, RecordLists -> True];
  First[r2];
  m2 = Rest[r2];
  {m // MatrixForm, m2 // MatrixForm}];
