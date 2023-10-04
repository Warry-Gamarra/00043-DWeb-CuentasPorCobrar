using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApi.Models
{
    public static class Mapper
    {
        public static FacultadModel FacultadDTO_To_FacultadModel(FacultadDTO facultadDTO)
        {
            if (facultadDTO == null)
                return null;

            FacultadModel facultadModel = new FacultadModel()
            {
                CodFac = facultadDTO.CodFac,
                FacDesc = facultadDTO.FacDesc,
                FacAbrev = facultadDTO.FacAbrev,
                DependenciaID = facultadDTO.DependenciaID,
                Habilitado = facultadDTO.Habilitado
            };

            return facultadModel;
        }

        public static EscuelaModel EscuelaDTO_To_EscuelaModel(EscuelaDTO escuelaDTO)
        {
            if (escuelaDTO == null)
                return null;

            EscuelaModel escuelaModel = new EscuelaModel()
            {
                CodEsc = escuelaDTO.CodEsc,
                CodFac = escuelaDTO.CodFac,
                EscDesc = escuelaDTO.EscDesc,
                EscAbrev = escuelaDTO.EscAbrev,
                Habilitado = escuelaDTO.Habilitado
            };

            return escuelaModel;
        }

        public static CarreraProfesionalModel CarreraProfesionalDTO_To_CarreraProfesionalModel(CarreraProfesionalDTO carreraProfesionalDTO)
        {
            if (carreraProfesionalDTO == null)
                return null;

            CarreraProfesionalModel carreraProfesionalModel = new CarreraProfesionalModel()
            {
                C_RcCod = carreraProfesionalDTO.C_RcCod,
                C_CodEsp = carreraProfesionalDTO.C_CodEsp,
                C_CodEsc = carreraProfesionalDTO.C_CodEsc,
                C_CodFac = carreraProfesionalDTO.C_CodFac,
                T_EspDesc = carreraProfesionalDTO.T_EspDesc,
                T_EscDesc = carreraProfesionalDTO.T_EscDesc,
                T_FacDesc = carreraProfesionalDTO.T_FacDesc,
                T_CarProfDesc = carreraProfesionalDTO.T_CarProfDesc,
                C_Tipo = carreraProfesionalDTO.C_Tipo,
                I_Duracion = carreraProfesionalDTO.I_Duracion,
                B_Anual = carreraProfesionalDTO.B_Anual,
                N_Grupo = carreraProfesionalDTO.N_Grupo,
                N_Grado = carreraProfesionalDTO.N_Grado,
                I_IdAplica = carreraProfesionalDTO.I_IdAplica,
                B_Habilitado = carreraProfesionalDTO.B_Habilitado,
                I_DependenciaID = carreraProfesionalDTO.I_DependenciaID,
            };

            return carreraProfesionalModel;
        }

        public static AlumnoEntity MantenimientoAlumnoModel_To_AlumnoEntity(MantenimientoAlumnoModel alumnoModel, int currentUserID)
        {
            if (alumnoModel == null)
                return null;

            AlumnoEntity alumnoEntity = new AlumnoEntity()
            {
                I_PersonaID = alumnoModel.I_PersonaID,
                C_NumDNI = alumnoModel.C_NumDNI,
                C_CodTipDoc = alumnoModel.C_CodTipDoc,
                T_ApePaterno = alumnoModel.T_ApePaterno,
                T_ApeMaterno = alumnoModel.T_ApeMaterno,
                T_Nombre = alumnoModel.T_Nombre,
                D_FecNac = alumnoModel.D_FecNac,
                C_Sexo = alumnoModel.C_Sexo,
                C_RcCod = alumnoModel.C_RcCod,
                C_CodAlu = alumnoModel.C_CodAlu,
                C_CodModIng = alumnoModel.C_CodModIng,
                C_AnioIngreso = alumnoModel.C_AnioIngreso,
                I_IdPlan = alumnoModel.I_IdPlan,
                B_Habilitado = alumnoModel.B_Habilitado,
                B_Eliminado = alumnoModel.B_Eliminado,
                CurrentUserID = currentUserID
            };

            return alumnoEntity;
        }

        public static AlumnoModel AlumnoDTO_To_AlumnoModel(AlumnoDTO alumnoDTO)
        {
            if (alumnoDTO == null)
                return null;

            AlumnoModel alumnoModel = new AlumnoModel()
            {
                I_PersonaID = alumnoDTO.I_PersonaID,
                C_CodTipDoc = alumnoDTO.C_CodTipDoc,
                T_TipDocDesc = alumnoDTO.T_TipDocDesc,
                C_NumDNI = alumnoDTO.C_NumDNI,
                T_ApePaterno = alumnoDTO.T_ApePaterno,
                T_ApeMaterno = alumnoDTO.T_ApeMaterno,
                T_Nombre = alumnoDTO.T_Nombre,
                D_FecNac = alumnoDTO.D_FecNac,
                C_Sexo = alumnoDTO.C_Sexo,
                C_CodAlu = alumnoDTO.C_CodAlu,
                C_RcCod = alumnoDTO.C_RcCod,
                C_CodEsp = alumnoDTO.C_CodEsp,
                C_CodEsc = alumnoDTO.C_CodEsc,
                T_EscDesc = alumnoDTO.T_EscDesc,
                C_CodFac = alumnoDTO.C_CodFac,
                T_FacDesc = alumnoDTO.T_FacDesc,
                C_CodProg = alumnoDTO.C_CodProg,
                T_DenomProg = alumnoDTO.T_DenomProg,
                C_CodModIng = alumnoDTO.C_CodModIng,
                T_ModIngDesc = alumnoDTO.T_ModIngDesc,
                N_Grado = alumnoDTO.N_Grado,
                T_GradoDesc = alumnoDTO.T_GradoDesc,
                N_Grupo = alumnoDTO.N_Grupo,
                C_AnioIngreso = alumnoDTO.C_AnioIngreso,
                I_IdPlan = alumnoDTO.I_IdPlan,
                B_Habilitado = alumnoDTO.B_Habilitado,
                I_DependenciaID = alumnoDTO.I_DependenciaID
            };

            return alumnoModel;
        }

        public static ProgramaUnfvEntity ProgramaUnfvModel_To_ProgramaUnfvEntity(MantenimientoProgramaUnfvModel programaUnfvModel, int currentUserID)
        {
            if (programaUnfvModel == null)
                return null;

            ProgramaUnfvEntity programaUnfvEntity = new ProgramaUnfvEntity()
            {
                C_RcCod = programaUnfvModel.C_RcCod,
                C_CodEsp = programaUnfvModel.C_CodEsp,
                C_CodEsc = programaUnfvModel.C_CodEsc,
                C_CodFac = programaUnfvModel.C_CodFac,
                C_Tipo = programaUnfvModel.C_Tipo,
                I_Duracion = programaUnfvModel.I_Duracion,
                B_Anual = programaUnfvModel.B_Anual,
                N_Grupo = programaUnfvModel.N_Grupo,
                N_Grado = programaUnfvModel.N_Grado,
                I_IdAplica = programaUnfvModel.I_IdAplica,
                C_CodProg = programaUnfvModel.C_CodProg,
                T_DenomProg = programaUnfvModel.T_DenomProg,
                T_Resolucion = programaUnfvModel.T_Resolucion,
                T_DenomGrado = programaUnfvModel.T_DenomGrado,
                T_DenomTitulo = programaUnfvModel.T_DenomTitulo,
                C_CodModEst = programaUnfvModel.C_CodModEst,
                B_SegundaEsp = programaUnfvModel.B_SegundaEsp,
                C_CodRegimenEst = programaUnfvModel.C_CodRegimenEst,
                C_CodGrado = programaUnfvModel.C_CodGrado,
                B_Habilitado = programaUnfvModel.B_Habilitado,
                B_Eliminado = programaUnfvModel.B_Eliminado,
                CurrentUserID = currentUserID
            };

            return programaUnfvEntity;
        }

        public static ProgramaUnfvModel ProgramaUnfvDTO_To_ProgramaUnfvModel(ProgramaUnfvDTO programaUnfvDTO)
        {
            if (programaUnfvDTO == null)
                return null;

            ProgramaUnfvModel programaUnfvModel = new ProgramaUnfvModel()
            {
                C_CodProg = programaUnfvDTO.C_CodProg,
                C_RcCod = programaUnfvDTO.C_RcCod,
                C_CodEsp = programaUnfvDTO.C_CodEsp,
                C_CodEsc = programaUnfvDTO.C_CodEsc,
                C_CodFac = programaUnfvDTO.C_CodFac,
                T_EspDesc = programaUnfvDTO.T_EspDesc,
                T_EscDesc = programaUnfvDTO.T_EscDesc,
                T_FacDesc = programaUnfvDTO.T_FacDesc,
                T_DenomProg = programaUnfvDTO.T_DenomProg,
                T_Resolucion = programaUnfvDTO.T_Resolucion,
                T_DenomGrado = programaUnfvDTO.T_DenomGrado,
                T_DenomTitulo = programaUnfvDTO.T_DenomTitulo,
                C_CodRegimenEst = programaUnfvDTO.C_CodRegimenEst,
                C_CodModEst = programaUnfvDTO.C_CodModEst,
                B_SegundaEsp = programaUnfvDTO.B_SegundaEsp,
                C_CodGrado = programaUnfvDTO.C_CodGrado,
                C_Tipo = programaUnfvDTO.C_Tipo,
                I_Duracion = programaUnfvDTO.I_Duracion,
                B_Anual = programaUnfvDTO.B_Anual,
                N_Grupo = programaUnfvDTO.N_Grupo,
                N_Grado = programaUnfvDTO.N_Grado,
                I_IdAplica = programaUnfvDTO.I_IdAplica,
                B_Habilitado = programaUnfvDTO.B_Habilitado
            };

            return programaUnfvModel;
        }
    }
}