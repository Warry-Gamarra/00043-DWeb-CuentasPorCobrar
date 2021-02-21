using Data.Procedures;
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

        public Estudiante()
        {
            _grabarMatricula = new USP_IU_GrabarMatricula();
        }

        public Response CargarDataAptos(string serverPath, HttpPostedFileBase file, TipoAlumno tipoAlumno, int currentUserId)
        {
            var result = new Response();
            string fileName = "";
            try
            {
                fileName = GuardarArchivoEnHost(serverPath, file);
                result = GuardarDatosRepositorio(serverPath + fileName, currentUserId);
                RemoverArchivo(serverPath, fileName);

                return result;
            }
            catch (Exception ex)
            {
                RemoverArchivo(serverPath, fileName);
                return new Response()
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

        private Response GuardarDatosRepositorio(string filePath, int currentUserId)
        {
            var resultados = new List<DataMatriculaResult>();

            var matriculaSource = MatriculaSourceFactory.GetMatriculaSource(Path.GetExtension(filePath));

            var dataMatriculas = matriculaSource.GetList(filePath);

            //Validando códigos duplicados.
            var codigosRepetidos = dataMatriculas.GroupBy(x => new { x.C_CodRC, x.C_CodAlu }).Where(x => x.Count() > 1);

            if (codigosRepetidos != null && codigosRepetidos.Count() > 0)
            {
                codigosRepetidos.ToList().ForEach(
                    c => c.ToList().ForEach(rep => {
                        resultados.Add(Mapper.DataMatriculaType_To_DataMatriculaResult(rep, false, "Código de alumno repetido."));

                        dataMatriculas.RemoveAll(mat => mat.C_CodRC == rep.C_CodRC && mat.C_CodAlu == rep.C_CodAlu);
                    })
                );
            }
            
            //Validando el campo año.
            resultados.AddRange(
                dataMatriculas.Where(CampoAnioIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaResult(mat, false, "El campo Año es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoAnioIncorrecto);

            //Validando el campo periodo.
            resultados.AddRange(
                dataMatriculas.Where(CampoPeriodoIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaResult(mat, false, "El campo Periodo es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoPeriodoIncorrecto);

            //Validando el campo estado.
            resultados.AddRange(
                dataMatriculas.Where(CampoEstadoIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaResult(mat, false, "El campo Estado es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoEstadoIncorrecto);

            //Validando el campo ingresante.
            resultados.AddRange(
                dataMatriculas.Where(CampoIngresanteIncorrecto).
                    Select(mat => Mapper.DataMatriculaType_To_DataMatriculaResult(mat, false, "El campo Ingresante es incorrecto."))
            );

            dataMatriculas.RemoveAll(CampoIngresanteIncorrecto);

            DataTable dataTable = Mapper.DataMatriculaTypeList_To_DataTable(dataMatriculas);

            _grabarMatricula.UserID = currentUserId;
            _grabarMatricula.D_FecRegistro = DateTime.Now;

            return new Response(_grabarMatricula.Execute(dataTable));
        }

        private void RemoverArchivo(string serverPath, string fileName)
        {
            System.IO.File.Delete(serverPath + fileName);
        }

        private static bool CampoAnioIncorrecto(DataMatriculaType dataMatricula)
        {
            return dataMatricula.I_Anio == null || dataMatricula.I_Anio < 1963;
        }

        private static bool CampoPeriodoIncorrecto(DataMatriculaType dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_Periodo);
        }

        private static bool CampoEstadoIncorrecto(DataMatriculaType dataMatricula)
        {
            return String.IsNullOrWhiteSpace(dataMatricula.C_EstMat);
        }

        private static bool CampoIngresanteIncorrecto(DataMatriculaType dataMatricula)
        {
            return dataMatricula.B_Ingresante == null;
        }
    }
}
