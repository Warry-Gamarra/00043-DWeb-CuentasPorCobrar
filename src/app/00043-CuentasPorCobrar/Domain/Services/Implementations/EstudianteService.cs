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

        public DataMatriculaResponse GrabarMatriculas(List<MatriculaEntity> dataMatriculas, bool alumnosPregado, int currentUserId)
        {
            var observados = new List<MatriculaObsEntity>();

            //Validando el código de alumno.
            observados.AddRange(
                dataMatriculas.Where(CampoCodigoAlumnoIncorrecto).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Código de alumno es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoCodigoAlumnoIncorrecto);

            //Validando el cod_rc.
            observados.AddRange(
                dataMatriculas.Where(CampoCodRcIncorrecto).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Cod_Rc es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoCodRcIncorrecto);

            //Validando códigos duplicados.
            var codigosRepetidos = dataMatriculas.GroupBy(x => new { x.C_CodRC, x.C_CodAlu }).Where(x => x.Count() > 1);

            if (codigosRepetidos != null && codigosRepetidos.Count() > 0)
            {
                codigosRepetidos.ToList().ForEach(
                    c => c.ToList().ForEach(rep => {
                        observados.Add(Mapper.MatriculaEntity_To_MatriculaObsEntity(rep, false, "Código de alumno repetido."));

                        dataMatriculas.RemoveAll(mat => mat.C_CodRC == rep.C_CodRC && mat.C_CodAlu == rep.C_CodAlu);
                    })
                );
            }

            //Validando el campo año.
            observados.AddRange(
                dataMatriculas.Where(CampoAnioIncorrecto).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Año es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoAnioIncorrecto);

            //Validando el campo periodo.
            observados.AddRange(
                dataMatriculas.Where(CampoPeriodoIncorrecto).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Periodo es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoPeriodoIncorrecto);

            //Validando el campo estado.
            observados.AddRange(
                dataMatriculas.Where(CampoEstadoIncorrecto).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Estado es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoEstadoIncorrecto);

            //Validando el campo ingresante.
            observados.AddRange(
                dataMatriculas.Where(CampoIngresanteIncorrecto).
                    Select(mat => Mapper.MatriculaEntity_To_MatriculaObsEntity(mat, false, "El campo Ingresante es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoIngresanteIncorrecto);

            if (dataMatriculas.Count > 0)
            {
                var grabarMatricula = new USP_IU_GrabarMatricula()
                {
                    B_AlumnosPregrado = alumnosPregado,
                    UserID = currentUserId,
                    D_FecRegistro = DateTime.Now
                };

                var dataTable = Mapper.MatriculaEntity_To_DataTable(dataMatriculas);

                var grabarMatriculaResult = grabarMatricula.Execute(dataTable);

                observados.AddRange(grabarMatriculaResult.Select(r => Mapper.DataMatriculaResult_To_MatriculaObsEntity(r)));
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

        private bool CampoCodigoAlumnoIncorrecto(MatriculaEntity dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_CodAlu) || dataMatricula.C_CodAlu.Length != 10;
        }

        private bool CampoCodRcIncorrecto(MatriculaEntity dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_CodRC) || dataMatricula.C_CodRC.Length != 3;
        }

        private bool CampoAnioIncorrecto(MatriculaEntity dataMatricula)
        {
            return dataMatricula.I_Anio == null || dataMatricula.I_Anio < 1963;
        }

        private bool CampoPeriodoIncorrecto(MatriculaEntity dataMatricula)
        {
            return !_periodos.Any(p => p.T_OpcionCod.Equals(dataMatricula.C_Periodo));
        }

        private bool CampoEstadoIncorrecto(MatriculaEntity dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_EstMat);
        }

        private bool CampoIngresanteIncorrecto(MatriculaEntity dataMatricula)
        {
            return dataMatricula.B_Ingresante == null;
        }
    }
}
