Add-Type -AssemblyName System.Web

function ParametersParser($url){
            $rawUrl = [string]$url
            $Parameters = @{}
            $rawUrl = $rawUrl.Split("?")
            $rawParameters = $rawUrl[1]
            if ($rawParameters) {
                $rawParameters = $rawParameters.Split("&")
                foreach ($rawParameter in $rawParameters) {
                    $Parameter = $rawParameter.Split("=")
                    $Parameters.Add($Parameter[0],([System.Web.HttpUtility]::UrlDecode($Parameter[1])))
                }
            }
            else { write-host "no parameters supplied." }

            return $Parameters

            }

# Http Server
$http = [System.Net.HttpListener]::new() 

# Hostname and port to listen on
$http.Prefixes.Add("http://*:8080/")

# Start the Http Server 
$http.Start()

while ($http.IsListening) {

    $context = $http.GetContext()

# SERVICES [get Parameters array from URL]
if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -match '/services') {
            

    $parameters = ParametersParser($context.Request.Url.OriginalString)

    $html = New-Object psobject -Property $parameters |ConvertTo-Html -Fragment


    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $context.Response.ContentLength64 = $buffer.Length
    $context.Response.OutputStream.Write($buffer, 0, $buffer.Length) 
    $context.Response.OutputStream.Close() 

    $http.Close()
}

# HOME 
    if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/') {
        
        [string]$html = "
            <html>
            <form action='/services' method='GET'>
                <p>Parameter1</p>
                <input type='text' name='Parameter1'>
                <p>Parameter2</p>
                <input type='text' name='Parameter2'>
                <br>
                <input type='submit' value='Submit'>
            </form>
            </html>
            "


        $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
        $context.Response.ContentLength64 = $buffer.Length
        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        $context.Response.OutputStream.Close() 
    
    }


} 
