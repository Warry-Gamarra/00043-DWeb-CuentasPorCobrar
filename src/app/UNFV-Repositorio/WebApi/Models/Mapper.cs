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

        public static EspecialidadModel EspecialidadDTO_To_EspecialidadModel(EspecialidadDTO especialidadDTO)
        {
            if (especialidadDTO == null)
                return null;

            EspecialidadModel especialidadModel = new EspecialidadModel()
            {
                CodEsp = especialidadDTO.CodEsp,
                CodEsc = especialidadDTO.CodEsc,
                CodFac = especialidadDTO.CodFac,
                EspDesc = especialidadDTO.EspDesc,
                EspAbrev = especialidadDTO.EspAbrev,
                Habilitado = especialidadDTO.Habilitado
            };

            return especialidadModel;
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
                T_DenomProg = alumnoDTO.T_DenomProg,
                C_CodModIng = alumnoDTO.C_CodModIng,
                T_ModIngDesc = alumnoDTO.T_ModIngDesc,
                C_AnioIngreso = alumnoDTO.C_AnioIngreso,
                I_IdPlan = alumnoDTO.I_IdPlan,
                B_Habilitado = alumnoDTO.B_Habilitado
            };

            return alumnoModel;
        }
    }
}