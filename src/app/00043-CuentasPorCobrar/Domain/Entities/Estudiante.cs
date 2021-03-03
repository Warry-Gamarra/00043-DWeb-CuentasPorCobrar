using Data.Procedures;
using Data.Tables;
using Data.Types;
using Domain.DTO;
using Domain.Helpers;
using Domain.Services;
using NDbfReader;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace Domain.Entities
{
    public class Estudiante : IEstudiante
    {
        private readonly USP_IU_GrabarMatricula _grabarMatricula;
        private readonly List<TC_CatalogoOpcion> _periodos;

        public Estudiante()
        {
            _grabarMatricula = new USP_IU_GrabarMatricula();
            _periodos = TC_CatalogoOpcion.FindByParametro((int)Parametro.Periodo);
        }

        public DataMatriculaResponse CargarDataAptos(string serverPath, HttpPostedFileBase file, TipoAlumno tipoAlumno, int currentUserId)
        {
            var response = new DataMatriculaResponse();
            string fileName = "";
            try
            {
                fileName = GuardarArchivoEnHost(serverPath, file);
                response = GuardarDatosRepositorio(serverPath + fileName, currentUserId);
                RemoverArchivo(serverPath, fileName);

                return response;
            }
            catch (Exception ex)
            {
                RemoverArchivo(serverPath, fileName);

                return new DataMatriculaResponse()
                {
                    Message = ex.Message
                };
            }
        }


        private string GuardarArchivoEnHost(string serverPath, HttpPostedFileBase file)
        {
            string fileName = Guid.NewGuid() + "__" + file.FileName;
            file.SaveAs(serverPath + fileName);

            return fileName;
        }

        private DataMatriculaResponse GuardarDatosRepositorio(string filePath, int currentUserId)
        {
            var observados = new List<DataMatriculaObs>();

            var matriculaSource = MatriculaSourceFactory.GetMatriculaSource(Path.GetExtension(filePath));

            var dataMatriculas = matriculaSource.GetList(filePath);

            //Validando el código de alumno.
            observados.AddRange(
                dataMatriculas.Where(CampoCodigoAlumnoIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaObs(mat, false, "El campo Código de alumno es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoCodigoAlumnoIncorrecto);

            //Validando el cod_rc.
            observados.AddRange(
                dataMatriculas.Where(CampoCodRcIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaObs(mat, false, "El campo Cod_Rc es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoCodRcIncorrecto);

            //Validando códigos duplicados.
            var codigosRepetidos = dataMatriculas.GroupBy(x => new { x.C_CodRC, x.C_CodAlu }).Where(x => x.Count() > 1);

            if (codigosRepetidos != null && codigosRepetidos.Count() > 0)
            {
                codigosRepetidos.ToList().ForEach(
                    c => c.ToList().ForEach(rep => {
                        observados.Add(Mapper.DataMatriculaType_To_DataMatriculaObs(rep, false, "Código de alumno repetido."));

                        dataMatriculas.RemoveAll(mat => mat.C_CodRC == rep.C_CodRC && mat.C_CodAlu == rep.C_CodAlu);
                    })
                );
            }
            
            //Validando el campo año.
            observados.AddRange(
                dataMatriculas.Where(CampoAnioIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaObs(mat, false, "El campo Año es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoAnioIncorrecto);

            //Validando el campo periodo.
            observados.AddRange(
                dataMatriculas.Where(CampoPeriodoIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaObs(mat, false, "El campo Periodo es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoPeriodoIncorrecto);

            //Validando el campo estado.
            observados.AddRange(
                dataMatriculas.Where(CampoEstadoIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaObs(mat, false, "El campo Estado es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoEstadoIncorrecto);

            //Validando el campo ingresante.
            observados.AddRange(
                dataMatriculas.Where(CampoIngresanteIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaObs(mat, false, "El campo Ingresante es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoIngresanteIncorrecto);
            
            if (dataMatriculas.Count > 0)
            {
                _grabarMatricula.UserID = currentUserId;

                _grabarMatricula.D_FecRegistro = DateTime.Now;

                var dataTable = Mapper.DataMatriculaTypeList_To_DataTable(dataMatriculas);

                var grabarMatriculaResult = _grabarMatricula.Execute(dataTable);

                observados.AddRange(Mapper.DataMatriculaResult_To_DataMatriculaObs(grabarMatriculaResult));
            }

            var result = new DataMatriculaResponse(observados);

            return result;
        }

        private void RemoverArchivo(string serverPath, string fileName)
        {
            System.IO.File.Delete(serverPath + fileName);
        }

        private bool CampoCodigoAlumnoIncorrecto(DataMatriculaType dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_CodAlu) || dataMatricula.C_CodAlu.Length != 10;
        }

        private bool CampoCodRcIncorrecto(DataMatriculaType dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_CodRC) || dataMatricula.C_CodRC.Length != 3;
        }

        private bool CampoAnioIncorrecto(DataMatriculaType dataMatricula)
        {
            return dataMatricula.I_Anio == null || dataMatricula.I_Anio < 1963;
        }

        private bool CampoPeriodoIncorrecto(DataMatriculaType dataMatricula)
        {
            //return String.IsNullOrWhiteSpace(dataMatricula.C_Periodo);
            return !_periodos.Any(p => p.T_OpcionCod.Equals(dataMatricula.C_Periodo));
        }

        private bool CampoEstadoIncorrecto(DataMatriculaType dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_EstMat);
        }

        private bool CampoIngresanteIncorrecto(DataMatriculaType dataMatricula)
        {
            return dataMatricula.B_Ingresante == null;
        }
    }
}
