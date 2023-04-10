Output examples/demo.gif

Set Shell "bash"
Set FontSize 20
Set Width 1550
Set Height 600
Set Padding 80
Set Theme "nord"

# Create file and stage it
Type "touch file"
Sleep 1
Enter
Type "git add file"
Sleep 1
Enter

# Enter program
Type "bash convenshional-commits.sh"
Sleep 500ms
Enter
Sleep 3

# Choose correct type of commit
Type "2"
Sleep 1
Enter
Sleep 3

# Enter commit scope
Type "file"
Sleep 2
Enter
Sleep 2

# Enter commit message
Type@100ms "add new file with a ridiculously long message"
Sleep 2
Enter
Sleep 2

# Confirm no ammend
Enter
Sleep 4
