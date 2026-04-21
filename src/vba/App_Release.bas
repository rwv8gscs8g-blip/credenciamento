Attribute VB_Name = "App_Release"
Option Explicit

' Metadata centralizada da release atual.
' O Menu_Principal apenas consome estas funcoes.

Public Const APP_RELEASE_ATUAL As String = "V12.0.0202"
Public Const APP_RELEASE_STATUS As String = "VALIDADO"
Public Const APP_RELEASE_CANAL As String = "DESENVOLVIMENTO"
Public Const APP_RELEASE_ALVO As String = "V12.0.0203"
Public Const APP_RELEASE_BUILD_KEY As String = "V12.0.0202|DESENVOLVIMENTO|V12.0.0203"
Public Const APP_RELEASE_TAG As String = "v12.0.0202"
Public Const APP_RELEASE_EVIDENCE_DIR As String = "auditoria/evidencias/V12.0.0202"
Public Const APP_RELEASE_TEST_KEY As String = "bo-2026-04-20+v2-2026-04-20"
Public Const APP_GITHUB_REPO_URL As String = "https://github.com/rwv8gscs8g-blip/credenciamento"
Public Const APP_GITHUB_RELEASE_NOTES_URL As String = APP_GITHUB_REPO_URL & "/tree/main/obsidian-vault/releases"

Public Function AppRelease_Atual() As String
    AppRelease_Atual = APP_RELEASE_ATUAL
End Function

Public Function AppRelease_Status() As String
    AppRelease_Status = APP_RELEASE_STATUS
End Function

Public Function AppRelease_Canal() As String
    AppRelease_Canal = APP_RELEASE_CANAL
End Function

Public Function AppRelease_Alvo() As String
    AppRelease_Alvo = APP_RELEASE_ALVO
End Function

Public Function AppRelease_BuildKey() As String
    AppRelease_BuildKey = APP_RELEASE_BUILD_KEY
End Function

Public Function AppRelease_Tag() As String
    AppRelease_Tag = APP_RELEASE_TAG
End Function

Public Function AppRelease_EvidenceDir() As String
    AppRelease_EvidenceDir = APP_RELEASE_EVIDENCE_DIR
End Function

Public Function AppRelease_TestKey() As String
    AppRelease_TestKey = APP_RELEASE_TEST_KEY
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

Public Function GetReleaseCanal() As String
    GetReleaseCanal = AppRelease_Canal()
End Function

Public Function GetReleaseAlvo() As String
    GetReleaseAlvo = AppRelease_Alvo()
End Function

Public Function GetReleaseBuildKey() As String
    GetReleaseBuildKey = AppRelease_BuildKey()
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

Public Function GetReleaseTag() As String
    GetReleaseTag = AppRelease_Tag()
End Function

Public Function GetReleaseEvidenceDir() As String
    GetReleaseEvidenceDir = AppRelease_EvidenceDir()
End Function

Public Function GetReleaseTestKey() As String
    GetReleaseTestKey = AppRelease_TestKey()
End Function
