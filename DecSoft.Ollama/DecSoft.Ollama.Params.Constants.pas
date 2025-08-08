(*
 MIT license

 Copyright (c) DecSoft Utils

 https://www.decsoftutils.com/
 https://github.com/dec/delphi-ollama

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
*)

unit DecSoft.Ollama.Params.Constants;

interface

uses
  DecSoft.Ollama.Chat.Types,
  DecSoft.Ollama.Params.Types,
  DecSoft.Ollama.Response.Types,
  DecSoft.Ollama.Generation.Types;

const

  DefaultOptionsParam: TOptionsParam = (
    Mirostat: 0;
    MirostatEta: 0.1;
    MirostatTau: 5.0;
    NumCtx: 2048;
    RepeatLastN: 64;
    RepeatPenalty: 1.1;
    Temperature: 0.8;
    Seed: 42;
    Stop: [];
    TfsZ: 1;
    NumPredict: 128;
    TopK: 40;
    TopP: 0.9;
    MinP: 0.0;
  );

  DefaultChatParams: TChatParams = (
    Model: 'gemma3';
    Think: False;
    Stream: False;
    KeepAlive: '5m';
    Tools: [];
    Messages: [];
  );

  DefaultGenerationParams: TGenerationParams = (
    Model: 'gemma3';
    Prompt: '';
    Suffix: '';
    Think: False;
    Stream: False;
    KeepAlive: '5m';
    Images: [];
    Format: TResponseFormat(crfText);
    Context: [];
  );

implementation

end.
