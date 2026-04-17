Attribute VB_Name = "App_Release"
Option Explicit

' Metadata centralizada da release atual.
' Fonte de verdade: vba_export/. O Menu_Principal apenas consome estas funcoes.

Public Const APP_RELEASE_ATUAL As String = "V12.0.0191"
Public Const APP_RELEASE_STATUS As String = "EM_VALIDACAO"
Public Const APP_GITHUB_REPO_URL As String = "https://github.com/rwv8gscs8g-blip/credenciamento"
Public Const APP_GITHUB_RELEASE_NOTES_URL As String = APP_GITHUB_REPO_URL & "/tree/main/obsidian-vault/releases"

Public Function AppRelease_Atual() As String
    AppRelease_Atual = APP_RELEASE_ATUAL
End Function

Public Function AppRelease_Status() As String
    AppRelease_Status = APP_RELEASE_STATUS
End Function

Public Function AppRelease_Iteracao() As String
    Dim partes() As String

    partes = Split(Replace$(APP_RELEASE_ATUAL, "V", ""), ".")
    If UBound(partes) >= 2 Then
        AppRelease_Iteracao = partes(2)
    Else
        AppRelease_Iteracao = APP_RELEASE_ATUAL
    End If
End Function

Public Function AppRelease_GitHubRepoUrl() As String
    AppRelease_GitHubRepoUrl = APP_GITHUB_REPO_URL
End Function

Public Function AppRelease_GitHubReleaseNotesUrl() As String
    AppRelease_GitHubReleaseNotesUrl = APP_GITHUB_RELEASE_NOTES_URL
End Function

Public Function GetReleaseAtual() As String
    GetReleaseAtual = AppRelease_Atual()
End Function

Public Function GetReleaseStatus() As String
    GetReleaseStatus = AppRelease_Status()
End Function

Public Function GetIteracaoAtual() As String
    GetIteracaoAtual = AppRelease_Iteracao()
End Function

Public Function GetGitHubRepoUrl() As String
    GetGitHubRepoUrl = AppRelease_GitHubRepoUrl()
End Function

Public Function GetGitHubReleaseNotesUrl() As String
    GetGitHubReleaseNotesUrl = AppRelease_GitHubReleaseNotesUrl()
End Function
