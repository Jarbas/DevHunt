unit AppExceptions;

interface

uses
  System.SysUtils;

type
  EAppException = class(Exception);

  EValidacao = class(EAppException);

  ERegistroNaoEncontrado = class(EAppException);

  EConfiguracao = class(EAppException);

implementation

end.
