@echo off
setlocal enabledelayedexpansion

:: Define a pasta raiz dos arquivos .ini
set "pasta_raiz=C:\Users\igor.briano\Desktop\teste_bat\pasta_ini"
set "arq_config=C:\Users\igor.briano\Desktop\teste_bat\config.txt"

:: 1. Carregamento das variáveis
if exist "%arq_config%" (
    for /f "usebackq tokens=1,2 delims==" %%a in ("%arq_config%") do (
        set "%%a=%%b"
    )
) else (
    echo [ERRO] O arquivo de configuracao '%arq_config%' nao foi encontrado.
    pause
    exit
)

:: 2. Verificação das variaveis
echo.
echo ==========================================
echo       CONFIGURACOES CARREGADAS
echo ==========================================
echo RPO ATUAL:  [%RPO_ATUAL%]
echo RPO FUTURO: [%RPO_FUTUR%]
echo ==========================================
echo.

:: 3. Verificação se as variáveis foram carregadas
if "%RPO_ATUAL%"=="" (
    echo [ERRO] O sistema ainda nao leu as variaveis.
) else (
    echo [SUCESSO] Variaveis carregadas!
)

input "Pressione Enter para continuar..."

:: 4. Iniciando processamento
echo.
echo Iniciando processamento...
echo De: %RPO_ATUAL% -^> Para: %RPO_FUTUR%
echo ------------------------------------------
echo.

:: 5. Alterando os arquivos .ini
for /r "%pasta_raiz%" %%f in (*.txt) do (
    :: Pega o nome da pasta atual
    for %%i in ("%%~dpf.") do (
        set "nomeDaPasta=%%~ni"
    )
    
    if /i "%%~nf"=="ServerApp_!nomeDaPasta!" (
        echo [OK] Processando: %%~nxf
        
        powershell -Command "(Get-Content -LiteralPath \"%%f\") -replace 'prd_%RPO_ATUAL%', 'prd_%RPO_FUTUR%' | Set-Content -LiteralPath \"%%f\""
    )
)

:: 6. Atualiza variaveis no arquivo de configuração
set /a numFuturo=100%RPO_FUTUR% %% 100
set /a proximoValor=%numFuturo% + 1

if %proximoValor% GTR 9 (
    set "proximoValor=1"
)

set "RPO_ATUAL_NOVO=%RPO_FUTUR%"

if %proximoValor% LSS 10 (
    set "proximoValor=00%proximoValor%"
) else if %proximoValor% LSS 100 (
    set "proximoValor=0%proximoValor%"
)

set "RPO_FUTUR_NOVO=%proximoValor%"

(
  echo RPO_ATUAL=%RPO_ATUAL_NOVO%
  echo RPO_FUTUR=%RPO_FUTUR_NOVO%
) > "%arq_config%"

:: 6. Verificação das variaveis
echo.
echo ==========================================
echo       CONFIGURACOES ATUALIZADAS
echo ==========================================
echo Novo RPO Atual: %RPO_ATUAL_NOVO%
echo Novo RPO Futuro: %RPO_FUTUR_NOVO%
echo ==========================================
echo.

echo.
echo Concluido!
pause