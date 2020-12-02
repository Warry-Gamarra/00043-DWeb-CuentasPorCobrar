using Data.Procedures;
using Data.Tables;
using Data.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public static class Mapper
    {
        public static USP_I_GrabarPersona AlumnoEntity_To_USP_I_GrabarPersona(AlumnoEntity alumnoEntity)
        {
            USP_I_GrabarPersona persona = new USP_I_GrabarPersona()
            {
                C_NumDNI = alumnoEntity.C_NumDNI,
                C_CodTipDoc = alumnoEntity.C_CodTipDoc,
                T_Nombre = alumnoEntity.T_Nombre,
                T_ApePaterno = alumnoEntity.T_ApePaterno,
                T_ApeMaterno = alumnoEntity.T_ApeMaterno,
                C_Sexo = alumnoEntity.C_Sexo,
                D_FecNac = alumnoEntity.D_FecNac,
                I_UsuarioCre = alumnoEntity.CurrentUserID,
                D_FecCre = alumnoEntity.CurrentDateTime
            };

            return persona;
        }

        public static USP_I_GrabarAlumno AlumnoEntity_To_USP_I_GrabarAlumno(AlumnoEntity alumnoEntity)
        {
            USP_I_GrabarAlumno alumno = new USP_I_GrabarAlumno()
            {
                I_PersonaID = alumnoEntity.I_PersonaID,
                C_CodAlu = alumnoEntity.C_CodAlu,
                C_RcCod = alumnoEntity.C_RcCod,
                C_AnioIngreso = alumnoEntity.C_AnioIngreso.Value,
                C_CodModIng = alumnoEntity.C_CodModIng,
                I_IdPlan = alumnoEntity.I_IdPlan.Value,
                I_UsuarioCre = alumnoEntity.CurrentUserID,
                D_FecCre = alumnoEntity.CurrentDateTime
            };

            return alumno;
        }

        public static USP_U_ActualizarPersona AlumnoEntity_To_USP_U_ActualizarPersona(AlumnoEntity alumnoEntity)
        {
            USP_U_ActualizarPersona persona = new USP_U_ActualizarPersona()
            {
                I_PersonaID = alumnoEntity.I_PersonaID,
                C_NumDNI = alumnoEntity.C_NumDNI,
                C_CodTipDoc = alumnoEntity.C_CodTipDoc,
                T_ApeMaterno = alumnoEntity.T_ApeMaterno,
                T_ApePaterno = alumnoEntity.T_ApePaterno,
                T_Nombre = alumnoEntity.T_Nombre,
                D_FecNac = alumnoEntity.D_FecNac,
                C_Sexo = alumnoEntity.C_Sexo,
                B_Habilitado = alumnoEntity.B_Habilitado,
                B_Eliminado = alumnoEntity.B_Eliminado,
                I_UsuarioMod = alumnoEntity.CurrentUserID,
                D_FecMod = alumnoEntity.CurrentDateTime
            };

            return persona;
        }

        public static USP_U_ActualizarAlumno AlumnoEntity_To_USP_U_ActualizarAlumno(AlumnoEntity alumnoEntity)
        {
            USP_U_ActualizarAlumno alumno = new USP_U_ActualizarAlumno()
            {
                C_CodAlu = alumnoEntity.C_CodAlu,
                C_RcCod = alumnoEntity.C_RcCod,
                C_CodModIng = alumnoEntity.C_CodModIng,
                C_AnioIngreso = alumnoEntity.C_AnioIngreso.Value,
                I_IdPlan = alumnoEntity.I_IdPlan.Value,
                I_PersonaID = alumnoEntity.I_PersonaID,
                B_Habilitado = alumnoEntity.B_Habilitado,
                B_Eliminado = alumnoEntity.B_Eliminado,
                I_UsuarioMod = alumnoEntity.CurrentUserID,
                D_FecMod = alumnoEntity.CurrentDateTime
            };

            return alumno;
        }

        public static AlumnoDTO VW_Alumnos_To_AlumnoDTO(VW_Alumnos alumno)
        {
            AlumnoDTO alumnoDTO = new AlumnoDTO()
            {
                I_PersonaID = alumno.I_PersonaID,
                C_CodTipDoc = alumno.C_CodTipDoc,
                T_TipDocDesc = alumno.T_TipDocDesc,
                C_NumDNI = alumno.C_NumDNI,
                T_ApePaterno = alumno.T_ApePaterno,
                T_ApeMaterno = alumno.T_ApeMaterno,
                T_Nombre = alumno.T_Nombre,
                D_FecNac = alumno.D_FecNac,
                C_Sexo = alumno.C_Sexo,
                C_CodAlu = alumno.C_CodAlu,
                C_RcCod = alumno.C_RcCod,
                T_DenomProg = alumno.T_DenomProg,
                C_CodModIng = alumno.C_CodModIng,
                T_ModIngDesc = alumno.T_ModIngDesc,
                C_AnioIngreso = alumno.C_AnioIngreso,
                I_IdPlan = alumno.I_IdPlan,
                B_Habilitado = alumno.B_Habilitado
            };

            return alumnoDTO;
        }

        public static FacultadDTO TC_Facultad_To_FacultadDTO(TC_Facultad facultad)
        {
            FacultadDTO facultadDTO = new FacultadDTO()
            {
                CodFac = facultad.C_CodFac,
                FacDesc = facultad.T_FacDesc,
                FacAbrev = facultad.T_FacAbrev,
                Habilitado = facultad.B_Habilitado
            };

            return facultadDTO;
        }

        public static EscuelaDTO TC_Escuela_To_EscuelaDTO(TC_Escuela escuela)
        {
            EscuelaDTO escuelaDTO = new EscuelaDTO()
            {
                CodEsc = escuela.C_CodEsc,
                CodFac = escuela.C_CodFac,
                EscDesc = escuela.T_EscDesc,
                EscAbrev = escuela.T_EscAbrev,
                Habilitado = escuela.B_Habilitado
            };

            return escuelaDTO;
        }

        public static EspecialidadDTO TC_Especialidad_To_EspecialidadDTO(TC_Especialidad especialidad)
        {
            EspecialidadDTO especialidadDTO = new EspecialidadDTO()
            {
                CodEsp = especialidad.C_CodEsp,
                CodEsc = especialidad.C_CodEsc,
                CodFac = especialidad.C_CodFac,
                EspDesc = especialidad.T_EspDesc,
                EspAbrev = especialidad.T_EspAbrev,
                Habilitado = especialidad.B_Habilitado
            };

            return especialidadDTO;
        }
    }
}
