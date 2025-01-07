# Charger l'assembly WPF
Add-Type -AssemblyName PresentationFramework

# Créer la fenêtre
$window = New-Object System.Windows.Window
$window.Title = "Mon Interface WPF"
#$window.SizeToContent = [System.Windows.SizeToContent]::WidthAndHeight  # Ajuster à la taille du contenu
$window.Width = 300


# Décoder l'image Base64
$base64Image = "/9j/4AAQSkZJRgABAQEAYABgAAD/4QAiRXhpZgAATU0AKgAAAAgAAQESAAMAAAABAAEAAAAAAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwY
HBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA
wMDAwMDAwMDAwMDAwMDAz/wAARCABnAeoDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9A
QIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqD
hIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQA
AAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKj
U2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2
Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9/PwNH4GufHxR8Nd9e0UD3vYv/iqZJ8U/Dca5Gv6EF9Wv4x/WtPq1X+VmH1in/MjocgJ1AJo2
5HHeuX1D4s+GdPs5ribXtHSC3++wvE4+vNfKH7Qn/BZvwD8JNSOjeGtP1DxtrxOBb2A4311YbK8TXfuQfrsvvdkeTmfEmXYFL6xVSb2W7foldn2sAP4gDQR
xgAY+lfmyP23P2wfjkd/gn4O6b4e0yUZhmvoXkc/9tJnjT/yHUeo/FH9vuxG8+FNA/wC2FpaSf+1q61klRfFUin6o8T/Xig9YUKsl3UXb8bP8D9Kix6nmkz
uZeMCvy4H/AAV4+PvwAuEt/ip8IoRaf8trnyZtMJ/H94lfTX7L/wDwVt+FX7TE9tp41K48La/dLxY6rtiz/uSfcesq2TYmEeayku8XdG+C43yvEVPYyk6cu
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
//2Q=="  # Remplace par ta chaîne Base64
$imageBytes = [System.Convert]::FromBase64String($base64Image)

# Créer un flux de mémoire à partir des octets
$memoryStream = New-Object System.IO.MemoryStream
$memoryStream.Write($imageBytes, 0, $imageBytes.Length)
$memoryStream.Position = 0  # Réinitialiser la position du flux

# Charger l'image à partir du flux
$bitmapImage = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmapImage.BeginInit()
$bitmapImage.StreamSource = $memoryStream
$bitmapImage.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
$bitmapImage.EndInit()
$bitmapImage.Freeze()

# Créer un contrôle Image pour le bandeau
$imageControl = New-Object System.Windows.Controls.Image
$imageControl.Source = $bitmapImage
$imageControl.Stretch = [System.Windows.Media.Stretch]::UniformToFill
$imageControl.Height = 100  # Hauteur du bandeau

# Créer un bouton
$button = New-Object System.Windows.Controls.Button
$button.Content = "Clique-moi !"
$button.Width = 100
$button.Height = 30
$button.HorizontalAlignment = 'Center'
$button.VerticalAlignment = 'Center'

# Ajouter une action au bouton
$button.Add_Click({
        [System.Windows.MessageBox]::Show("Bouton cliqué !")
    })

# Créer un StackPanel pour contenir l'image et le bouton
$stackPanel = New-Object System.Windows.Controls.StackPanel
$stackPanel.Children.Add($imageControl)
$stackPanel.Children.Add($button)

# Définir le contenu de la fenêtre
$window.Content = $stackPanel

# Afficher la fenêtre
$window.ShowDialog() | Out-Null
