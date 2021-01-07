using Data.Procedures;
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
            var dataTable = new DataTable();

            dataTable.Columns.Add("c_codrc");
            dataTable.Columns.Add("c_codalu");
            dataTable.Columns.Add("I_Anio");
            dataTable.Columns.Add("C_Periodo");
            dataTable.Columns.Add("c_estmat");
            dataTable.Columns.Add("c_ciclo");
            dataTable.Columns.Add("b_ingresan");
            
            using (var table = Table.Open(pathFile))
            {
                var reader = table.OpenReader(Encoding.ASCII);
                while (reader.Read())
                {
                    //UTF8Encoding utf8 = new UTF8Encoding();
                    //byte[] encodedBytes = Encoding.Default.GetBytes(reader.GetString("NOM_ALU"));

                    dataTable.Rows.Add(
                        reader.GetString("COD_RC"),
                        reader.GetString("COD_ALU"),
                        reader.GetInt32("ANO"),
                        reader.GetString("P"),
                        reader.GetString("EST_MAT"),
                        reader.GetString("NIVEL"),
                        reader.GetBoolean("ES_INGRESA")
                        //utf8.GetString(encodedBytes)
                    );
                }
            }

            _grabarMatricula.UserID = currentUserId;
            _grabarMatricula.D_FecRegistro = DateTime.Now;

            return new Response(_grabarMatricula.Execute(dataTable));
        }

        private void RemoverArchivo(string serverPath, string fileName)
        {
            System.IO.File.Delete(serverPath + fileName);
        }

    }
}
