Import-Module PSReadLine;
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle InlineView;

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward;
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward;
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete;

$PSHomeDir = Split-Path $PROFILE;

oh-my-posh init pwsh --config $PSHomeDir/the-unnamed.omp.json | Invoke-Expression

# Alias
Set-Alias -Name ni -Value npm install;
Set-Alias -Name pni -Value pnpm install;
Set-Alias -Name pna -Value pnpm add;
Set-Alias -Name nt -Value npm run test;
Set-Alias -Name nd -Value npm run dev;
Set-Alias -Name nb -Value npm run build;
Set-Alias -Name nl -Value npm run lint:fix;
Set-Alias -Name ns -Value npm run start;
Set-Alias -Name np -Value npm publish --access public;
Set-Alias -Name proxy -Value Set-PSProxy;

# which命令
function which($name){
    try{
        $obj=Get-Command $name -ErrorAction Stop;
    }catch{
        Write-Host $name ': not found';
        return;
    }
    if($obj.CommandType -eq 'Alias'){
        -Join($name,':Is alias ',$obj.Name,' -> ',$obj.Definition);
    }elseif($obj.CommandType -eq 'Function'){
        -Join($name,':Is built in Function');
    }
    else{
        $obj.Source;
    }
}

Function Set-PSProxy {
    [CmdletBinding()]
    Param ( 
            [Parameter(
                Position = 0,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true
                )]
            [ValidateNotNullOrEmpty()]
            [Alias("Host")]
            [String]$Proxy = "http://127.0.0.1:33210",

            [switch]$off
          )

    Process {
        if ($off) {
            Remove-Item Env:http_proxy -ErrorAction SilentlyContinue;
            Remove-Item Env:https_proxy -ErrorAction SilentlyContinue;
        }else {
            if($Env:http_proxy -or $Env:https_proxy) {
                Remove-Item Env:http_proxy -ErrorAction SilentlyContinue;
                Remove-Item Env:https_proxy -ErrorAction SilentlyContinue;
                $off = $true;
            } else{
                $Env:http_proxy=$Proxy;
                $Env:https_proxy=$Proxy;
            }
        }
    }

    End {
        if($off) {
            Write-Output "取消代理";
            if($Env:http_proxy -or $Env:https_proxy){
                Write-Host "代理未成功取消";
            }
        }else {

            Write-Output "设置代理为:";
            if($Env:http_proxy){Write-Output "Http: ${Env:http_proxy}";}
            if($Env:http_proxy){Write-Output "Https: ${Env:https_proxy}";}
        }
    }
}

Function Set-NetProxy {
    [CmdletBinding()]
    Param (
            [Parameter(
                Position = 0,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true
                )]
            [ValidateNotNullOrEmpty()]
            [Alias("Host")]
            [String]$Proxy = "127.0.0.1:33210",

            [Parameter(
                Position = 1,
                Mandatory = $False,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true
                )]
            [AllowEmptyString()]
            [Alias("Pac")]
            [String]$acs,

            [switch]$off
          )

    Begin {
        $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings";
    }

    Process {
        if($off) {
            Set-ItemProperty -Path $regKey ProxyEnable -value 0 -ErrorAction SilentlyContinue;
            Set-ItemProperty -Path $regKey ProxyServer -value "" -ErrorAction SilentlyContinue;
            Set-ItemProperty -Path $regKey AutoConfigURL -value "" -ErrorAction SilentlyContinue;
        }else {
            Set-ItemProperty -Path $regKey ProxyEnable -value 1;
            Set-ItemProperty -Path $regKey ProxyServer -value $Proxy;
            
            if($acs) {
                Set-ItemProperty -Path $regKey AutoConfigURL -value $acs;
            }
        }
    }

    End {
        if($off) {
            Write-Output "System proxy is now Disabled";
        }else {
            Write-Output "System porxy is now enabled.";
            Write-Output "Proxy Server: $Proxy";
        }
    }
}



