Attribute VB_Name = "AppContext"
Option Explicit

' TAppContext esta definido em AAA_Types.bas (antigo Mod_Types.bas, renomeado para compilar primeiro).
Private ctx As TAppContext

Public Function GetContext() As TAppContext
    GetContext = ctx
End Function

Public Sub SetPreOS(ByRef preos As TPreOS)
    ctx.PreOS_Corrente = preos
    ctx.IsPreOSValida = True
End Sub

Public Sub SetOS(ByRef os As TOS)
    ctx.OS_Corrente = os
    ctx.IsOSValida = True
End Sub

Public Sub SetEmpresa(ByRef emp As TEmpresa)
    ctx.Empresa_Selecionada = emp
    ctx.IsEmpresaValida = True
End Sub

Public Sub SetEntidade(ByRef ent As TEntidade)
    ctx.Entidade_Selecionada = ent
    ctx.IsEntidadeValida = True
End Sub

Public Sub SetConfig(ByRef cfg As TConfig)
    ctx.Config = cfg
End Sub

Public Sub Invalidate()
    Dim emptyPreOS As TPreOS
    Dim emptyOS As TOS
    Dim emptyEmp As TEmpresa
    Dim emptyEnt As TEntidade

    ctx.PreOS_Corrente = emptyPreOS
    ctx.OS_Corrente = emptyOS
    ctx.Empresa_Selecionada = emptyEmp
    ctx.Entidade_Selecionada = emptyEnt

    ctx.IsPreOSValida = False
    ctx.IsOSValida = False
    ctx.IsEmpresaValida = False
    ctx.IsEntidadeValida = False
End Sub


