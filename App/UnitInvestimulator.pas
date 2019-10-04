unit UnitInvestimulator;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Samples.Spin,
  UnitTxtUtils,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TFormInvestimulator = class(TForm)
    PageControlInvestimulator: TPageControl;
    TabSheetTodos: TTabSheet;
    TabSheetTesouroDireto: TTabSheet;
    MemoTodosInvestimentos: TMemo;
    ButtonTesouroDiretoSimular: TButton;
    MemoTesouroDireto: TMemo;
    GroupBoxTesouroDireto: TGroupBox;
    EditValorAplicadoTD: TEdit;
    LabelValorAplicadoTD: TLabel;
    SpinEditQtdDiasTD: TSpinEdit;
    LabelQtdDiasTD: TLabel;
    RadioButtonSelic: TRadioButton;
    RadioButtonPrefixadoSemestrais: TRadioButton;
    RadioButtonPrefixado: TRadioButton;
    RadioButtonIPCA: TRadioButton;
    RadioButtonIPCASemestrais: TRadioButton;
    RadioButtonTaxaPreTD: TRadioButton;
    RadioButtonTaxaPosTD: TRadioButton;
    TabSheetPoupanca: TTabSheet;
    MemoPoupanca: TMemo;
    GroupBoxPoupanca: TGroupBox;
    LabelValoAplicadoPoupanca: TLabel;
    LabelQtdDiasPoupanca: TLabel;
    EditValorAplicadoPoupanca: TEdit;
    SpinEditQtdDiasPoupanca: TSpinEdit;
    RadioButtonPoupanca: TRadioButton;
    ButtonSimularPoupanca: TButton;
    TabSheetCDB: TTabSheet;
    MemoCDB: TMemo;
    GroupBoxCDB: TGroupBox;
    RadioButtonTaxaPreCDB: TRadioButton;
    RadioButtonTaxaPosCDB: TRadioButton;
    LabelValorAplicadoCDB: TLabel;
    LabelQtdDiasCDB: TLabel;
    EditValorAplicadoCDB: TEdit;
    SpinEditQtdDiasCDB: TSpinEdit;
    ButtonSimularrCDB: TButton;
    ComboBoxCDBBancos: TComboBox;
    LabelCDBBancos: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ButtonTesouroDiretoSimularClick(Sender: TObject);
    procedure EditValorAplicadoTDKeyPress(Sender: TObject; var Key: Char);
    procedure EditValorAplicadoPoupancaKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonSimularPoupancaClick(Sender: TObject);
    procedure EditValorAplicadoCDBKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonSimularrCDBClick(Sender: TObject);
  private
    FGravarArquivo: TGravar;
    procedure ValidarValor_Dias(Valor: string; Dias: Integer);
    procedure ValidarTesouroDireto;
    procedure ValidarPoupanca;
    procedure ValidarCDB;
    procedure ValidarCurrencyImput(Teclas: Char; Tecla: string);
    procedure SimularTesouroDireto;
    procedure SimularPoupanca;
    procedure SimularCDB;
    procedure LerDadosMemo;
    procedure LimparCampos;
    function PegarTipoTD: string;
    function PegarTipoTaxaBase(RadioPreFixado, RadioPosFixado: Boolean): string;
    procedure GravarSimulacoesPadrao(PathArquivoSimulado, Conteudo: string);
    function PegarTipoTaxaTD: string;
    function PegarTipoTaxaCDB: string;
    function PegarBancoCDB: string;
  public
    procedure EvalidationErrorMsg(Msg: string);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FormInvestimulator: TFormInvestimulator;

implementation

{$R *.dfm}

uses
  UnitEvalidationError,
  UnitCalculo,
  UnitDadosUtils,
  StrUtils;

procedure TFormInvestimulator.ButtonSimularPoupancaClick(Sender: TObject);
begin
  SimularPoupanca;
end;

procedure TFormInvestimulator.ButtonSimularrCDBClick(Sender: TObject);
begin
  SimularCDB;
end;

procedure TFormInvestimulator.ButtonTesouroDiretoSimularClick(Sender: TObject);
begin
  SimularTesouroDireto;
end;

constructor TFormInvestimulator.Create(AOwner: TComponent);
begin
  inherited;
  FGravarArquivo := TGravar.Create;
end;

destructor TFormInvestimulator.Destroy;
begin
  FGravarArquivo.Free;
  inherited;
end;

procedure TFormInvestimulator.EditValorAplicadoCDBKeyPress(Sender: TObject; var Key: Char);
begin
  ValidarCurrencyImput(Key, EditValorAplicadoCDB.Text);
end;

procedure TFormInvestimulator.EditValorAplicadoTDKeyPress(Sender: TObject; var Key: Char);
begin
  ValidarCurrencyImput(Key, EditValorAplicadoTD.Text);
end;

procedure TFormInvestimulator.EditValorAplicadoPoupancaKeyPress(Sender: TObject; var Key: Char);
begin
  ValidarCurrencyImput(Key, EditValorAplicadoPoupanca.Text);
end;

procedure TFormInvestimulator.EvalidationErrorMsg(Msg: string);
begin
  raise EValidationError.Create(Msg);
end;

procedure TFormInvestimulator.FormShow(Sender: TObject);
begin
  LerDadosMemo;
  PageControlInvestimulator.ActivePageIndex := 0;
end;

procedure TFormInvestimulator.GravarSimulacoesPadrao(PathArquivoSimulado, Conteudo: string);
begin
  if (not PathArquivoSimulado.IsEmpty)  and (not Conteudo.IsEmpty) then
  begin
    FGravarArquivo.GravarTxt(PathArquivoSimulado, Conteudo);
    LimparCampos;
    LerDadosMemo;
  end
  else
    EvalidationErrorMsg('Error');
end;

procedure TFormInvestimulator.LerDadosMemo;
begin
  MemoTodosInvestimentos.Lines.LoadFromFile(PathTodosInvestimentos);
  MemoTesouroDireto.Lines.LoadFromFile(PathArquivoTesouroDireto);
  MemoPoupanca.Lines.LoadFromFile(PathArquivoPoupanca);
  MemoCDB.Lines.LoadFromFile(PathArquivoCertificadoDepositoBancario);
end;

procedure TFormInvestimulator.LimparCampos;
begin
  RadioButtonSelic.Checked := False;
  RadioButtonPrefixadoSemestrais.Checked := False;
  RadioButtonPrefixado.Checked := False;
  RadioButtonIPCA.Checked := False;
  RadioButtonIPCASemestrais.Checked := False;
  RadioButtonTaxaPreTD.Checked := False;
  RadioButtonTaxaPosTD.Checked := False;
  EditValorAplicadoTD.Clear;
  SpinEditQtdDiasTD.Clear;

  EditValorAplicadoPoupanca.Clear;
  SpinEditQtdDiasPoupanca.Clear;

  EditValorAplicadoCDB.Clear;
  SpinEditQtdDiasCDB.Clear;
  RadioButtonTaxaPreCDB.Checked := False;
  RadioButtonTaxaPosCDB.Checked := False;
  ComboBoxCDBBancos.ItemIndex := -1;
end;

function TFormInvestimulator.PegarBancoCDB: string;
const
  NenhumBancoSelecionado = -1;
  SelecionarBanco = '� necess�rio selecionar um Banco para simular';
begin
  if (ComboBoxCDBBancos.ItemIndex = NenhumBancoSelecionado)  then
    EvalidationErrorMsg(SelecionarBanco)
  else
    Exit(ComboBoxCDBBancos.Text);
end;

function TFormInvestimulator.PegarTipoTaxaBase(RadioPreFixado, RadioPosFixado: Boolean): string;
begin
  if RadioPreFixado then
    Exit(TaxaPreFixado)
  else if RadioPosFixado then
    Exit(TaxaPosFixado)
  else
    EvalidationErrorMsg(TaxaAplicacaoNecessario);
end;

function TFormInvestimulator.PegarTipoTaxaCDB: string;
begin
  Result := PegarTipoTaxaBase(RadioButtonTaxaPreCDB.Checked, RadioButtonTaxaPosCDB.Checked);
end;

function TFormInvestimulator.PegarTipoTaxaTD: string;
begin
  Result := PegarTipoTaxaBase(RadioButtonTaxaPreTD.Checked, RadioButtonTaxaPosTD.Checked);
end;

function TFormInvestimulator.PegarTipoTD: string;
begin
  if RadioButtonSelic.Checked then
    Exit(TesouroSelic)
  else if RadioButtonPrefixado.Checked then
    Exit(TesouroPrefixado)
  else if RadioButtonPrefixadoSemestrais.Checked then
    Exit(TesouroPrefixadoSemestrais)
  else if RadioButtonIPCA.Checked then
    Exit(TesouroIPCA)
  else if RadioButtonIPCASemestrais.Checked then
    Exit(TesouroIPCASemestrais)
  else
    EvalidationErrorMsg(TesouroSelicNecessario);
end;

procedure TFormInvestimulator.SimularCDB;
var
  BancoSelecionado, TextoCDB: string;
  RendimentoPorcentagemCDB, TaxaCDI_CDB: Double;
  ValorCDBFinal: Currency;
begin
  ValorCDBFinal := 0.0;
  ValidarCDB;
  BancoSelecionado := PegarBancoCDB;
  TaxaCDI_CDB := TCalculo.TaxaCDI_Radon;
  RendimentoPorcentagemCDB := TCalculo.TaxaCDB(SpinEditQtdDiasCDB.Value);

  if RadioButtonTaxaPreCDB.Checked then
    ValorCDBFinal := TCalculo.CertificadoDepositoBancarioPre(StrToCurr(EditValorAplicadoCDB.Text),
      SpinEditQtdDiasCDB.Value, TaxaCDI_Aleatorio)
  else if RadioButtonTaxaPosCDB.Checked then
    ValorCDBFinal := TCalculo.CertificadoDepositoBancarioPos(StrToCurr(EditValorAplicadoCDB.Text),
      SpinEditQtdDiasCDB.Value, TaxaCDI_CDB)
  else
    EvalidationErrorMsg('Error');

  TextoCDB := FGravarArquivo.TextoPadraoCertificadoDepositoBancario(EditValorAplicadoCDB.Text, PegarTipoTaxaCDB,
    BancoSelecionado, RendimentoPorcentagemCDB, TaxaCDI_CDB, ValorCDBFinal, SpinEditQtdDiasCDB.Value);

  GravarSimulacoesPadrao(PathArquivoCertificadoDepositoBancario, TextoCDB);
end;

procedure TFormInvestimulator.SimularPoupanca;
var
  ValorFinal: Currency;
  TaxaPoupancaFinal, TaxaCDIFinal: Double;
  TextoPoupanca: string;
begin
  ValidarPoupanca;

  TaxaPoupancaFinal := TCalculo.TaxaPoupanca(SpinEditQtdDiasPoupanca.Value);
  TaxaCDIFinal := TCalculo.TaxaCDI_Radon;
  ValorFinal := TCalculo.Poupanca(StrToCurr(EditValorAplicadoPoupanca.Text), SpinEditQtdDiasPoupanca.Value, TaxaCDIFinal);

  TextoPoupanca := FGravarArquivo.TextoPadraoPoupanca(EditValorAplicadoPoupanca.Text, TaxaPoupancaFinal,
    TaxaCDIFinal, ValorFinal, SpinEditQtdDiasPoupanca.Value);

  GravarSimulacoesPadrao(PathArquivoPoupanca, TextoPoupanca);
end;

procedure TFormInvestimulator.SimularTesouroDireto;
var
  ValorFinal: Currency;
  TaxaSelicFinal, TaxaCDIFinal: Double;
  IOF180, IOF360, IOF720, IOF_Mais720: Currency;
  TextoTesouroDireto: string;
const
  RendimentoConvenvional: array[0..2] of string = (TesouroSelic, TesouroPrefixado, TesouroIPCA);
  RendimentoSemestral: array[0..1] of string = (TesouroPrefixadoSemestrais, TesouroIPCASemestrais);
begin
  ValorFinal := 0.0;
  ValidarTesouroDireto;
  TaxaCDIFinal := TCalculo.TaxaCDI_Radon;
  TaxaSelicFinal := TCalculo.TaxaSelic(SpinEditQtdDiasTD.Value);

  if PegarTipoTaxaTD = TaxaPreFixado then
  begin
    if MatchStr(PegarTipoTD, RendimentoConvenvional) then
      ValorFinal := TCalculo.TesouroSelicTaxasPre(StrToCurr(EditValorAplicadoTD.Text), SpinEditQtdDiasTD.Value, TaxaCDI_Aleatorio)
    else
      ValorFinal := TCalculo.TesouroSemestraisTaxasPre(StrToCurr(EditValorAplicadoTD.Text), SpinEditQtdDiasTD.Value, TaxaCDI_Aleatorio)
  end
  else if PegarTipoTaxaTD = TaxaPosFixado then
  begin
    if MatchStr(PegarTipoTD, RendimentoConvenvional) then
      ValorFinal := TCalculo.TesouroSelicTaxasPos(StrToCurr(EditValorAplicadoTD.Text), SpinEditQtdDiasTD.Value, TaxaCDIFinal)
    else
      ValorFinal := TCalculo.TesouroSemestraisTaxasPos(StrToCurr(EditValorAplicadoTD.Text), SpinEditQtdDiasTD.Value, TaxaCDIFinal)
  end
  else
    EvalidationErrorMsg('Erro');

  IOF180 := TCalculo.TesouroIOF_180(StrToCurr(EditValorAplicadoTD.Text));
  IOF360 := TCalculo.TesouroIOF_360(StrToCurr(EditValorAplicadoTD.Text));
  IOF720 := TCalculo.TesouroIOF_720(StrToCurr(EditValorAplicadoTD.Text));
  IOF_Mais720 := TCalculo.TesouroIOF_Mais720(StrToCurr(EditValorAplicadoTD.Text));

  TextoTesouroDireto := FGravarArquivo.TextoPadraoTesouroDireto(EditValorAplicadoTD.Text, PegarTipoTD, PegarTipoTaxaTD,
    TaxaSelicFinal, TaxaCDIFinal, IOF180, IOF360, IOF720, IOF_Mais720, ValorFinal, SpinEditQtdDiasTD.Value);

  GravarSimulacoesPadrao(PathArquivoTesouroDireto, TextoTesouroDireto);
end;

procedure TFormInvestimulator.ValidarCurrencyImput(Teclas: Char; Tecla: string);
const
  SeparadorDecimal = ',';
  TeclaNaoPermitida = 'Car�cter inv�lido, s� � permitido valores de moeda';
  VirgulaApenasUmaVez = 'V�rgula permitida apenas uma vez';
begin
  if not (Teclas in [#8, '0'..'9', SeparadorDecimal]) then
  begin
    ShowMessage(TeclaNaoPermitida);
    Abort;
  end
  else if (Teclas = SeparadorDecimal) and (Pos(Teclas, Tecla) > 0) then
  begin
    ShowMessage(VirgulaApenasUmaVez);
    Abort;
  end;
end;

procedure TFormInvestimulator.ValidarValor_Dias(Valor: string; Dias: Integer);
begin
  if Valor = EmptyStr then
    EvalidationErrorMsg(ValorAplicadoInvalido)
  else if Dias <= 0 then
    EvalidationErrorMsg(QuantidadeInvalida);
end;

procedure TFormInvestimulator.ValidarPoupanca;
begin
  ValidarValor_Dias(EditValorAplicadoPoupanca.Text, SpinEditQtdDiasPoupanca.Value);
end;

procedure TFormInvestimulator.ValidarTesouroDireto;
begin
  ValidarValor_Dias(EditValorAplicadoTD.Text, SpinEditQtdDiasTD.Value);
end;

procedure TFormInvestimulator.ValidarCDB;
begin
  ValidarValor_Dias(EditValorAplicadoCDB.Text, SpinEditQtdDiasCDB.Value);
end;

end.
