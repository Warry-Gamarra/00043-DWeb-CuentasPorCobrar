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
        private readonly USP_IU_GrabarAlumnosAptos _grabarAptos;

        public Estudiante()
        {
            _grabarAptos = new USP_IU_GrabarAlumnosAptos();
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

            dataTable.Columns.Add("C_Anio");
            dataTable.Columns.Add("C_CodAlu");
            dataTable.Columns.Add("C_CodRC");
            dataTable.Columns.Add("I_IdPlan");
            dataTable.Columns.Add("C_EstMat");
            dataTable.Columns.Add("C_Nivel");
            dataTable.Columns.Add("T_ApmAlu");
            dataTable.Columns.Add("T_AppAlu");
            dataTable.Columns.Add("T_Nombre");
            dataTable.Columns.Add("T_NomAlu");

            using (var table = Table.Open(pathFile))
            {
                var reader = table.OpenReader(Encoding.ASCII);
                while (reader.Read())
                {
                    //UTF8Encoding utf8 = new UTF8Encoding();
                    //byte[] encodedBytes = Encoding.Default.GetBytes(reader.GetString("NOM_ALU"));

                    dataTable.Rows.Add(
                        reader.GetString("ANO"),
                        reader.GetString("COD_ALU"),
                        reader.GetString("COD_RC"),
                        Convert.ToInt32(reader.GetDecimal("ID_PLAN")),
                        reader.GetString("EST_MAT"),
                        reader.GetString("NIVEL"),
                        "", "", "",
                        //utf8.GetString(encodedBytes));
                        reader.GetString("NOM_ALU"));
                }
            }

            _grabarAptos.UserID = currentUserId;
            _grabarAptos.D_FecRegistro = DateTime.Now;

            return new Response(_grabarAptos.Execute(dataTable));
        }

        private void RemoverArchivo(string serverPath, string fileName)
        {
            System.IO.File.Delete(serverPath + fileName);
        }

    }
}
