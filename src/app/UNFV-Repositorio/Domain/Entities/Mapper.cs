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
                C_NumDNI = alumno.C_NumDNI == null ? "" : alumno.C_NumDNI,
                T_ApePaterno = alumno.T_ApePaterno == null ? "" : alumno.T_ApePaterno,
                T_ApeMaterno = alumno.T_ApeMaterno == null ? "" : alumno.T_ApeMaterno,
                T_Nombre = alumno.T_Nombre == null ? "" : alumno.T_Nombre,
                D_FecNac = alumno.D_FecNac,
                C_Sexo = alumno.C_Sexo,
                C_CodAlu = alumno.C_CodAlu,
                C_RcCod = alumno.C_RcCod,
                C_CodEsp = alumno.C_CodEsp,
                C_CodEsc = alumno.C_CodEsc,
                C_CodFac = alumno.C_CodFac,
                T_DenomProg = alumno.T_DenomProg,
                C_CodModIng = alumno.C_CodModIng,
                T_ModIngDesc = alumno.T_ModIngDesc,
                N_Grado = alumno.N_Grado,
                T_GradoDesc = alumno.T_GradoDesc,
                N_Grupo = alumno.N_Grupo,
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

        public static USP_I_GrabarCarreraProfesional AlumnoEntity_To_USP_I_GrabarCarreraProfesional(ProgramaUnfvEntity programaUnfvEntity)
        {
            USP_I_GrabarCarreraProfesional alumno = new USP_I_GrabarCarreraProfesional()
            {
                C_RcCod = programaUnfvEntity.C_RcCod,
                C_CodEsp = programaUnfvEntity.C_CodEsp,
                C_CodEsc = programaUnfvEntity.C_CodEsc,
                C_CodFac = programaUnfvEntity.C_CodFac,
                C_Tipo = programaUnfvEntity.C_Tipo,
                I_Duracion = programaUnfvEntity.I_Duracion.Value,
                B_Anual = programaUnfvEntity.B_Anual.Value,
                N_Grupo = programaUnfvEntity.N_Grupo,
                N_Grado = programaUnfvEntity.N_Grado,
                I_IdAplica = programaUnfvEntity.I_IdAplica,
                I_UsuarioCre = programaUnfvEntity.CurrentUserID,
                D_FecCre = programaUnfvEntity.CurrentDateTime
            };

            return alumno;
        }

        public static USP_I_GrabarProgramaUnfv AlumnoEntity_To_USP_I_GrabarProgramaUnfv(ProgramaUnfvEntity programaUnfvEntity)
        {
            USP_I_GrabarProgramaUnfv alumno = new USP_I_GrabarProgramaUnfv()
            {
                C_CodProg = programaUnfvEntity.C_CodProg,
                C_RcCod = programaUnfvEntity.C_RcCod,
                T_DenomProg = programaUnfvEntity.T_DenomProg,
                T_Resolucion = programaUnfvEntity.T_Resolucion,
                C_CodGrado = programaUnfvEntity.C_CodGrado,
                T_DenomGrado = programaUnfvEntity.T_DenomGrado,
                T_DenomTitulo = programaUnfvEntity.T_DenomTitulo,
                C_CodRegimenEst = programaUnfvEntity.C_CodRegimenEst,
                C_CodModEst = programaUnfvEntity.C_CodModEst,
                B_SegundaEsp = programaUnfvEntity.B_SegundaEsp,
                I_UsuarioCre = programaUnfvEntity.CurrentUserID,
                D_FecCre = programaUnfvEntity.CurrentDateTime
            };

            return alumno;
        }

        public static USP_U_ActualizarCarreraProfesional AlumnoEntity_To_USP_U_ActualizarCarreraProfesional(ProgramaUnfvEntity programaUnfvEntity)
        {
            USP_U_ActualizarCarreraProfesional alumno = new USP_U_ActualizarCarreraProfesional()
            {
                C_RcCod = programaUnfvEntity.C_RcCod,
                C_CodEsp = programaUnfvEntity.C_CodEsp,
                C_CodEsc = programaUnfvEntity.C_CodEsc,
                C_CodFac = programaUnfvEntity.C_CodFac,
                C_Tipo = programaUnfvEntity.C_Tipo,
                I_Duracion = programaUnfvEntity.I_Duracion.Value,
                B_Anual = programaUnfvEntity.B_Anual.Value,
                N_Grupo = programaUnfvEntity.N_Grupo,
                N_Grado = programaUnfvEntity.N_Grado,
                I_IdAplica = programaUnfvEntity.I_IdAplica,
                B_Habilitado = programaUnfvEntity.B_Habilitado,
                B_Eliminado = programaUnfvEntity.B_Habilitado,
                I_UsuarioMod = programaUnfvEntity.CurrentUserID,
                D_FecMod = programaUnfvEntity.CurrentDateTime
            };

            return alumno;
        }

        public static USP_U_ActualizarProgramaUnfv AlumnoEntity_To_USP_U_ActualizarProgramaUnfv(ProgramaUnfvEntity programaUnfvEntity)
        {
            USP_U_ActualizarProgramaUnfv alumno = new USP_U_ActualizarProgramaUnfv()
            {
                C_CodProg = programaUnfvEntity.C_CodProg,
                C_RcCod = programaUnfvEntity.C_RcCod,
                T_DenomProg = programaUnfvEntity.T_DenomProg,
                T_Resolucion = programaUnfvEntity.T_Resolucion,
                C_CodGrado = programaUnfvEntity.C_CodGrado,
                T_DenomGrado = programaUnfvEntity.T_DenomGrado,
                T_DenomTitulo = programaUnfvEntity.T_DenomTitulo,
                C_CodRegimenEst = programaUnfvEntity.C_CodRegimenEst,
                C_CodModEst = programaUnfvEntity.C_CodModEst,
                B_SegundaEsp = programaUnfvEntity.B_SegundaEsp,
                B_Habilitado = programaUnfvEntity.B_Habilitado,
                B_Eliminado = programaUnfvEntity.B_Eliminado,
                I_UsuarioMod = programaUnfvEntity.CurrentUserID,
                D_FecMod = programaUnfvEntity.CurrentDateTime
            };

            return alumno;
        }

        public static ProgramaUnfvDTO VW_ProgramaUnfv_To_ProgramaUnfvDTO(VW_ProgramaUnfv programaUnfv)
        {
            ProgramaUnfvDTO programaUnfvDTO = new ProgramaUnfvDTO()
            {
                C_CodProg = programaUnfv.C_CodProg,
                C_RcCod = programaUnfv.C_RcCod,
                C_CodEsp = programaUnfv.C_CodEsp,
                C_CodEsc = programaUnfv.C_CodEsc,
                C_CodFac = programaUnfv.C_CodFac,
                T_EspDesc = programaUnfv.T_EspDesc,
                T_EscDesc = programaUnfv.T_EscDesc,
                T_FacDesc = programaUnfv.T_FacDesc,
                T_DenomProg = programaUnfv.T_DenomProg,
                T_Resolucion = programaUnfv.T_Resolucion,
                T_DenomGrado = programaUnfv.T_DenomGrado,
                T_DenomTitulo = programaUnfv.T_DenomTitulo,
                C_CodRegimenEst = programaUnfv.C_CodRegimenEst,
                C_CodModEst = programaUnfv.C_CodModEst,
                B_SegundaEsp = programaUnfv.B_SegundaEsp,
                C_CodGrado = programaUnfv.C_CodGrado,
                C_Tipo = programaUnfv.C_Tipo,
                I_Duracion = programaUnfv.I_Duracion,
                B_Anual = programaUnfv.B_Anual,
                N_Grupo = programaUnfv.N_Grupo,
                N_Grado = programaUnfv.N_Grado,
                I_IdAplica = programaUnfv.I_IdAplica,
                B_Habilitado = programaUnfv.B_Habilitado
            };

            return programaUnfvDTO;
        }

        public static CarreraProfesionalDTO VW_CarreraProfesional_To_CarreraProfesionalDTO(VW_CarreraProfesional carreraProfesional)
        {
            CarreraProfesionalDTO carreraProfesionalDTO = new CarreraProfesionalDTO()
            {
                C_RcCod = carreraProfesional.C_RcCod,
                C_CodEsp = carreraProfesional.C_CodEsp,
                C_CodEsc = carreraProfesional.C_CodEsc,
                C_CodFac = carreraProfesional.C_CodFac,
                T_EspDesc = carreraProfesional.T_EspDesc,
                T_EscDesc = carreraProfesional.T_EscDesc,
                T_FacDesc = carreraProfesional.T_FacDesc,
                T_CarProfDesc = carreraProfesional.T_CarProfDesc,
                C_Tipo = carreraProfesional.C_Tipo,
                I_Duracion = carreraProfesional.I_Duracion,
                B_Anual = carreraProfesional.B_Anual,
                N_Grupo = carreraProfesional.N_Grupo,
                N_Grado = carreraProfesional.N_Grado,
                I_IdAplica = carreraProfesional.I_IdAplica,
                B_Habilitado = carreraProfesional.B_Habilitado,
                B_Eliminado = carreraProfesional.B_Eliminado,
            };

            return carreraProfesionalDTO;
        }
    }
}
