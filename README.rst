**math4ti2.m** is an interface package, allowing the execution of
``zsolve`` of the package 4ti2_ from within Mathematica notebooks. The
package is written by `Ralf Hemmecke`_ and `Silviu Radu`_.


Licence
=======

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details. You
should have received a copy of the GNU General Public License along
with this program. If not, see https://www.gnu.org/licenses.

Installation
============

For using the package, download the following file and put it into a
directory where Mathematica will find it.
::

    math4ti2.m

For a demonstration of how to use the package see `math4ti2.nb`_.


Configuration
=============

Most probably, you must adapt the line

::

   zsolvecmd = "/usr/bin/4ti2-zsolve"; (* location debian package 4ti2 *)

in ``math4ti2.m`` in order to call the command from 4ti2_ (that you
must install separately).


Installation instructions for 4ti2
==================================

Ubuntu/Debian
-------------

You need to have sudo rights on your computer.
Install via your package manager.
::

   sudo apt install 4ti2

The configuration of ``math4ti2.m`` is not needed since ``zsolve``
will be available as ``/usr/bin/4ti2-zsolve``.


MacOS
------

You need some prerequisites.
::

   brew install binutils gcc gmp make gawk
   brew upgrade

Now download, compile and install 4ti2_.
::

   curl -L https://github.com/4ti2/4ti2/releases/download/Release_1_6_9/4ti2-1.6.9.tar.gz > 4ti2-1.6.9.tar.gz
   tar xf 4ti2-1.6.9.tar.gz -C $HOME/software

   cd $HOME/software/4ti2-1.6.9
   ./configure --prefix=$HOME/software/4ti2
   make
   make install-exec

Windows
-------

Windows users need to download a Linux environment to accomodate the
use of the "4ti2" package. We recommend Cygwin. Download
https://cygwin.com/setup-x86_64.exe and run as administrator. In the
package management screen, select the following for installation:
``binutils``, ``gcc-core``, ``gcc-g++``, ``gmp``, ``make``, ``wget``.

In the Cygwin terminal download 4ti2_ and compile and install it as in
the instructions for MacOS above.

.. _4ti2: https://4ti2.github.io/
.. _Ralf Hemmecke: http://ralf.hemmecke.org
.. _Silviu Radu: https://risc.jku.at/m/cristian-silviu-radu/
.. _math4ti2.nb: https://www.risc.jku.at/research/combinat/software/math4ti2/math4ti2.nb
