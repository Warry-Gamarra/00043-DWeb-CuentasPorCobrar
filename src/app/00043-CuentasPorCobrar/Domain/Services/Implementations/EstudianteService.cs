using Data.Procedures;
using Data.Tables;
using Data.Types;
using Data.Views;
using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Domain.Services.Implementations
{
    public class EstudianteService : IEstudianteService
    {
        private readonly List<TC_CatalogoOpcion> _periodos;

        public EstudianteService()
        {
            _periodos = TC_CatalogoOpcion.FindByParametro((int)Parametro.Periodo);
        }

        public DataMatriculaResponse GrabarMatriculas(List<MatriculaEntity> dataMatriculas, TipoAlumno tipoAlumno, int currentUserId)
        {
            bool alumnosPregado = (tipoAlumno == TipoAlumno.Pregrado);

            var observados = new List<MatriculaObsEntity>();

            //Validando el código de alumno.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoCodigoAlumnoIncorrecto(mat.C_CodAlu)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Código de alumno es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoCodigoAlumnoIncorrecto(mat.C_CodAlu));

            //Validando el cod_rc.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoCodRcIncorrecto(mat.C_CodRC)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Cod_Rc es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoCodRcIncorrecto(mat.C_CodRC));

            //Validando el campo año.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoAnioIncorrecto(mat.I_Anio)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Año es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoAnioIncorrecto(mat.I_Anio));

            //Validando el campo periodo.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoPeriodoIncorrecto(mat.C_Periodo)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Periodo es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoPeriodoIncorrecto(mat.C_Periodo));

            //Validando  codigo de curso
            if (tipoAlumno.Equals(TipoAlumno.Pregrado))
            {
                observados.AddRange(
                    dataMatriculas.Where(mat => CampoCodCursoIncorrecto(mat.C_CodCurso)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo CodCurso es incorrecto."))
                );

                dataMatriculas.RemoveAll(mat => CampoCodCursoIncorrecto(mat.C_CodCurso));
            }

            //Validando códigos duplicados.
            var codigosRepetidos = dataMatriculas.GroupBy(x => new { x.C_CodRC, x.C_CodAlu, x.I_Anio, x.C_Periodo, x.C_CodCurso}).Where(x => x.Count() > 1);

            if (codigosRepetidos != null && codigosRepetidos.Count() > 0)
            {
                codigosRepetidos.ToList().ForEach(
                    c => c.ToList().ForEach(rep => {
                        observados.Add(Mapper.MatriculaEntity_To_MatriculaObsEntity(rep, false, "Registro repetido."));

                        dataMatriculas.RemoveAll(mat => mat.C_CodRC == rep.C_CodRC && mat.C_CodAlu == rep.C_CodAlu && mat.C_Periodo == rep.C_Periodo);
                    })
                );
            }

            //Validando el campo estado.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoEstadoIncorrecto(mat.C_EstMat)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Estado es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoEstadoIncorrecto(mat.C_EstMat));

            //Validando el campo ingresante.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoIngresanteIncorrecto(mat.B_Ingresante)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Ingresante es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoIngresanteIncorrecto(mat.B_Ingresante));
            
            //Validando el campo Creditos.
            observados.AddRange(
                dataMatriculas.Where(mat => CampoCreditoIncorrecto(mat.I_CredDesaprob, mat.I_Vez)).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Créditos es incorrecto."))
            );

            dataMatriculas.RemoveAll(mat => CampoCreditoIncorrecto(mat.I_CredDesaprob, mat.I_Vez));

            if (tipoAlumno.Equals(TipoAlumno.Pregrado))
            {
                //Validando el campo vez.
                observados.AddRange(
                    dataMatriculas.Where(mat => CampoVezIncorrecto(mat.I_CredDesaprob, mat.I_Vez)).
                        Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Vez es incorrecto."))
                );

                dataMatriculas.RemoveAll(mat => CampoVezIncorrecto(mat.I_CredDesaprob, mat.I_Vez));
            }
            
            if (dataMatriculas.Count > 0)
            {
                var grabarMatricula = new USP_IU_GrabarMatricula()
                {
                    B_AlumnosPregrado = alumnosPregado,
                    UserID = currentUserId,
                    D_FecRegistro = DateTime.Now,
                    I_TipoEstudio = tipoAlumno.Equals(TipoAlumno.Posgrado) ? 2 : (tipoAlumno.Equals(TipoAlumno.SegundaEspecialidad) ? 3 : (tipoAlumno.Equals(TipoAlumno.Residentado) ? 4 : 1))
                };

                var dataTable = Mapper.MatriculaEntity_To_DataTable(dataMatriculas);

                var grabarMatriculaResult = grabarMatricula.Execute(dataTable);

                observados.AddRange(grabarMatriculaResult.Where(r => !r.B_Success).Select(r => Mapper.DataMatriculaResult_To_MatriculaObsEntity(r)));
            }

            var result = new DataMatriculaResponse(observados);

            return result;
        }

        public IEnumerable<MatriculaDTO> GetMatriculaPregrado(int anio, int periodo)
        {
            var matriculas = VW_MatriculaAlumno.GetPregrado(anio, periodo);

            var result = matriculas.Select(m => Mapper.MatriculaDTO_To_VW_MatriculaAlumno(m));

            return result;
        }

        public IEnumerable<MatriculaDTO> GetMatriculaPosgrado(int anio, int periodo)
        {
            var matriculas = VW_MatriculaAlumno.GetPosgrado(anio, periodo);

            var result = matriculas.Select(m => Mapper.MatriculaDTO_To_VW_MatriculaAlumno(m));

            return result;
        }

        public IEnumerable<MatriculaDTO> GetMatriculaSegundaEspecialidad(int anio, int periodo)
        {
            var matriculas = VW_MatriculaAlumno.GetSegundaEspecialidad(anio, periodo);

            var result = matriculas.Select(m => Mapper.MatriculaDTO_To_VW_MatriculaAlumno(m));

            return result;
        }

        public IEnumerable<MatriculaDTO> GetMatriculaResidentado(int anio, int periodo)
        {
            var matriculas = VW_MatriculaAlumno.GetResidentado(anio, periodo);

            var result = matriculas.Select(m => Mapper.MatriculaDTO_To_VW_MatriculaAlumno(m));

            return result;
        }

        private bool CampoCodigoAlumnoIncorrecto(string codigoAlumno)
        {
            return String.IsNullOrWhiteSpace(codigoAlumno) || codigoAlumno.Length != 10;
        }

        private bool CampoCodRcIncorrecto(string codRc)
        {
            return String.IsNullOrWhiteSpace(codRc) || codRc.Length != 3;
        }

        private bool CampoAnioIncorrecto(int? anio)
        {
            return anio == null || anio < 1963;
        }

        private bool CampoPeriodoIncorrecto(string periodo)
        {
            return !_periodos.Any(p => p.T_OpcionCod.Equals(periodo));
        }

        private bool CampoEstadoIncorrecto(string estMat)
        {
            return String.IsNullOrWhiteSpace(estMat);
        }

        private bool CampoIngresanteIncorrecto(bool? B_Ingresante)
        {
            return B_Ingresante == null;
        }

        private bool CampoCodCursoIncorrecto(string codCur)
        {
            return String.IsNullOrWhiteSpace(codCur);
        }

        private bool CampoCreditoIncorrecto(int? I_CredDesaprob, int? vez)
        {
            if (!I_CredDesaprob.HasValue || I_CredDesaprob.Value < 0)
            {
                return true;
            }
            else
            {
                if (vez.HasValue && vez.Value > 1 && I_CredDesaprob.Value == 0)
                {
                    return true;
                }
            }

            return false;
        }

        private bool CampoVezIncorrecto(int? I_CredDesaprob, int? vez)
        {
            if (!vez.HasValue || vez.Value < 1)
            {
                return true;
            }
            else
            {
                if (I_CredDesaprob.HasValue && I_CredDesaprob.Value > 0 && vez.Value == 1)
                {
                    return true;
                }
            }

            return false;
        }

        public MultaNoVotarResponse GrabarAlumnosConMultaPorVoto(List<AlumnoMultaNoVotarEntity> alumnoMultaNoVotarEntity, int currentUserId)
        {
            var observados = new List<MultaNoVotarSinRegistrarEntity>();

            //Validando el código de alumno.
            observados.AddRange(
                alumnoMultaNoVotarEntity.Where(a => CampoCodigoAlumnoIncorrecto(a.C_CodAlu)).
                    Select(a => Mapper.AlumnoMultaNoVotarEntity_To_MultaNoVotarSinRegistrarEntity(a, false, "El campo Código de alumno es incorrecto."))
            );

            alumnoMultaNoVotarEntity.RemoveAll(a => CampoCodigoAlumnoIncorrecto(a.C_CodAlu));

            //Validando el cod_rc.
            observados.AddRange(
                alumnoMultaNoVotarEntity.Where(a => CampoCodRcIncorrecto(a.C_CodRC)).
                    Select(a => Mapper.AlumnoMultaNoVotarEntity_To_MultaNoVotarSinRegistrarEntity(a, false, "El campo Cod_Rc es incorrecto."))
            );

            alumnoMultaNoVotarEntity.RemoveAll(a => CampoCodRcIncorrecto(a.C_CodRC));

            //Validando códigos duplicados.
            var codigosRepetidos = alumnoMultaNoVotarEntity.GroupBy(x => new { x.C_CodRC, x.C_CodAlu }).Where(x => x.Count() > 1);

            if (codigosRepetidos != null && codigosRepetidos.Count() > 0)
            {
                codigosRepetidos.ToList().ForEach(
                    c => c.ToList().ForEach(rep => {
                        observados.Add(Mapper.AlumnoMultaNoVotarEntity_To_MultaNoVotarSinRegistrarEntity(rep, false, "Código de alumno repetido."));

                        alumnoMultaNoVotarEntity.RemoveAll(a => a.C_CodRC == rep.C_CodRC && a.C_CodAlu == rep.C_CodAlu);
                    })
                );
            }

            //Validando el campo año.
            observados.AddRange(
                alumnoMultaNoVotarEntity.Where(a => CampoAnioIncorrecto(a.I_Anio)).
                    Select(a => Mapper.AlumnoMultaNoVotarEntity_To_MultaNoVotarSinRegistrarEntity(a, false, "El campo Año es incorrecto."))
            );

            alumnoMultaNoVotarEntity.RemoveAll(a => CampoAnioIncorrecto(a.I_Anio));

            //Validando el campo periodo.
            observados.AddRange(
                alumnoMultaNoVotarEntity.Where(a => CampoPeriodoIncorrecto(a.C_Periodo)).
                    Select(a => Mapper.AlumnoMultaNoVotarEntity_To_MultaNoVotarSinRegistrarEntity(a, false, "El campo Periodo es incorrecto."))
            );

            alumnoMultaNoVotarEntity.RemoveAll(a => CampoPeriodoIncorrecto(a.C_Periodo));

            if (alumnoMultaNoVotarEntity.Count > 0)
            {
                var grabarAlumnosSinVoto = new USP_I_GrabarAlumnoMultaNoVotar()
                {
                    UserID = currentUserId,
                    D_FecRegistro = DateTime.Now
                };

                var dataTable = Mapper.AlumnoMultaNoVotarEntity_To_DataTable(alumnoMultaNoVotarEntity);

                var grabarAlumnosSinVotoResult = grabarAlumnosSinVoto.Execute(dataTable);

                observados.AddRange(grabarAlumnosSinVotoResult.Select(r => Mapper.MultaNoVotarResult_To_MultaNoVotarSinRegistrarEntity(r)));
            }

            var result = new MultaNoVotarResponse(observados);

            return result;
        }

        public MatriculaDTO GetMatricula(int anio, int periodo, string codAlu, string codRc)
        {
            MatriculaDTO result = null;

            var matricula = VW_MatriculaAlumno.GetMatricula(anio, periodo, codAlu, codRc);

            if (matricula != null)
            {
                result = Mapper.MatriculaDTO_To_VW_MatriculaAlumno(matricula);
            }

            return result;
        }

        public string GetNombresCompletos(string codAlu)
        {
            return VW_MatriculaAlumno.GetNombresCompletos(codAlu);
        }
    }
}
