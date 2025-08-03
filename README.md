
DecSoft Ollama Delphi Library
-----------------------------

Many thanks for your interest in this repository. The DecSoft Ollama Delphi
Library is intended to work with [Ollama](https://github.com/ollama/ollama)
from [Delphi]([Delphi](https://www.embarcadero.com/products/delphi)).

This library is mainly intended to be used in my own projects and have no
intention to be exhaustively completed, even when I will try to add the
missing features if my main job let me to do it.


What Delphi version are supported?
----------------------------------

I can't be sure what versions of Delphi are supported: I just can say that
the library is developed with Delphi 10.4, so, probably can be used "as is"
in later versions too. About the previous versions... probably the library
cannot run "as is", but you are completely free to fork this repository
and make the changes that you consider.


What more I needed?
-------------------

You need to [download Ollama for Windows](https://ollama.com/download/windows),
install it, pull some models and run it. The demos works by default with the
"gemma3" model, but, allows to change (just by providing the model name in a
TEdit control) it if you want to try any other model.

Note there is a "GenerationVision" demo which is intended to be used with a model
who have the "vision" capability. The "gemma3" model have this capability. Anyway,
in principle, if everything is OK, and, you try to use this specific demo with a
"non vision supported" model, the code must gracefully end with some kind of error.


What features are included right now?
-------------------------------------

Right now the library support the below features of the
[Ollama API](https://ollama.readthedocs.io/en/api/):

* **Generate a completion:** The "Generate a completion" feature is almost
complete: may some possible minor missing things can exists, but, probably
right now is quite usable.

* **Generate a chat completion:** The "Generate a chat completion" feature
is almost complete: may some possible minor missing things can exists, but,
probably right now is quite usable.

* **List local models:** The "List local models" feature is implemented but
only returns the models names.

* **List local models:** The "Version" request to get the Ollama version.


Is the library well documented?
-------------------------------

I am afraid that the answer is no. It's quite important that you read the
[Ollama API documentation](https://ollama.readthedocs.io/en/api/) in order
to use this library. On the other hand, even when it's not documented
(maybe in the future I can do some efforts on this topic)  the source code
is available and you are completely free to take a look!

Additionally, with the library various examples are included, so probably
you can start from scratch without too much problems.


Inspiration
-----------

I am very inspired by the great
[Delphi OpenAI library](https://github.com/HemulGM/DelphiOpenAI) developed
by [@HemulGM](https://github.com/HemulGM). What this mean is that I write
the source code in a way that I never try before, basically using some
modern features of the Delphi language, like "references to procedures",
for example. In addition, I almost steal certain Base64 unit used in
the [Delphi OpenAI library](https://github.com/HemulGM/DelphiOpenAI),
so many, many thanks [@HemulGM](https://github.com/HemulGM) for that!


MIT license
-----------

Copyright (c) DecSoft Utils - https://www.decsoftutils.com/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.