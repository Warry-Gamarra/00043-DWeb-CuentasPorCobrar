using Data.Procedures;
using Data.Types;
using Domain.DTO;
using Domain.Services;
using NDbfReader;
using System;
using System.Collections.Generic;
using System.Data;
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

        private Response GuardarDatosRepositorio(string pathFile, int currentUserId)
        {
            var dataMatricula = new List<DataMatriculaType>();
                        
            using (var table = Table.Open(pathFile))
            {
                var reader = table.OpenReader(Encoding.ASCII);
                while (reader.Read())
                {
                    dataMatricula.Add(new DataMatriculaType()
                    {
                        C_CodRC = reader.GetString("COD_RC"),
                        C_CodAlu = reader.GetString("COD_ALU"),
                        I_Anio = reader.GetInt32("ANO"),
                        C_Periodo = reader.GetString("P"),
                        C_EstMat = reader.GetString("EST_MAT"),
                        C_Ciclo = reader.GetString("NIVEL"),
                       B_Ingresante = reader.GetBoolean("ES_INGRESA")
                    });
                }
            }

            

            _grabarMatricula.UserID = currentUserId;
            _grabarMatricula.D_FecRegistro = DateTime.Now;

            return new Response(_grabarMatricula.Execute(dataMatricula));
        }

        private void RemoverArchivo(string serverPath, string fileName)
        {
            System.IO.File.Delete(serverPath + fileName);
        }

    }
}
