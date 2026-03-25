# Apply humanizer pattern updates to the 3 remaining repos
# Run from PowerShell: .\scripts\apply_humanizer_updates.ps1
# This copies the updated files from JuryTrial_Redux worktree to the other repos

$source = "C:\Users\jensenn\Research\repos\JuryTrial_Redux\.claude\worktrees\optimistic-visvesvaraya\.claude"

# Writing-Voice repo
$wv = "C:\Users\jensenn\Research\repos\Writing-Voice\.claude"
if (Test-Path $wv) {
    Copy-Item "$source\agents\writer.md" "$wv\agents\writer.md" -Force
    Copy-Item "$source\agents\writer-critic.md" "$wv\agents\writer-critic.md" -Force
    Copy-Item "$source\skills\write\SKILL.md" "$wv\skills\write\SKILL.md" -Force
    if (Test-Path "$wv\agents\mccloskey-fixer.md") {
        Copy-Item "$source\agents\mccloskey-fixer.md" "$wv\agents\mccloskey-fixer.md" -Force
    }
    if (Test-Path "$wv\skills\draft-slop-fixer\SKILL.md") {
        Copy-Item "$source\skills\draft-slop-fixer\SKILL.md" "$wv\skills\draft-slop-fixer\SKILL.md" -Force
    }
    Write-Host "Writing-Voice: updated"
    Set-Location $wv\..
    git add -A; git commit -m "feat: expand humanizer patterns with empirically documented AI giveaways (Feyzollahi & Rafizadeh 2025; Walther et al.)"
} else { Write-Host "Writing-Voice: not found at $wv" }

# clo-author-template
$clo = "C:\Users\jensenn\Research\repos\clo-author-template\.claude"
if (Test-Path $clo) {
    Copy-Item "$source\agents\writer.md" "$clo\agents\writer.md" -Force
    Copy-Item "$source\agents\writer-critic.md" "$clo\agents\writer-critic.md" -Force
    Copy-Item "$source\skills\write\SKILL.md" "$clo\skills\write\SKILL.md" -Force
    if (Test-Path "$clo\agents\mccloskey-fixer.md") {
        Copy-Item "$source\agents\mccloskey-fixer.md" "$clo\agents\mccloskey-fixer.md" -Force
    }
    if (Test-Path "$clo\skills\draft-slop-fixer\SKILL.md") {
        Copy-Item "$source\skills\draft-slop-fixer\SKILL.md" "$clo\skills\draft-slop-fixer\SKILL.md" -Force
    }
    Write-Host "clo-author-template: updated"
    Set-Location $clo\..
    git add -A; git commit -m "feat: expand humanizer patterns with empirically documented AI giveaways (Feyzollahi & Rafizadeh 2025; Walther et al.)"
} else { Write-Host "clo-author-template: not found at $clo" }

# claude-econ-paper-template
$econ = "C:\Users\jensenn\Research\repos\claude-econ-paper-template\.claude"
if (Test-Path $econ) {
    # This repo may have different file names -- copy what exists
    if (Test-Path "$econ\agents\writer.md") {
        Copy-Item "$source\agents\writer.md" "$econ\agents\writer.md" -Force
    }
    if (Test-Path "$econ\agents\writer-critic.md") {
        Copy-Item "$source\agents\writer-critic.md" "$econ\agents\writer-critic.md" -Force
    }
    if (Test-Path "$econ\agents\mccloskey-fixer.md") {
        Copy-Item "$source\agents\mccloskey-fixer.md" "$econ\agents\mccloskey-fixer.md" -Force
    }
    if (Test-Path "$econ\skills\write\SKILL.md") {
        Copy-Item "$source\skills\write\SKILL.md" "$econ\skills\write\SKILL.md" -Force
    }
    if (Test-Path "$econ\skills\draft-slop-fixer\SKILL.md") {
        Copy-Item "$source\skills\draft-slop-fixer\SKILL.md" "$econ\skills\draft-slop-fixer\SKILL.md" -Force
    }
    Write-Host "claude-econ-paper-template: updated"
    Set-Location $econ\..
    git add -A; git commit -m "feat: expand humanizer patterns with empirically documented AI giveaways (Feyzollahi & Rafizadeh 2025; Walther et al.)"
} else { Write-Host "claude-econ-paper-template: not found at $econ" }

Write-Host "`nDone. Review git log in each repo to confirm commits."
