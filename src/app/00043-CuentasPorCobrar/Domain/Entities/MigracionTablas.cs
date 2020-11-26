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
    public class MigracionTablas : IMigracionTablas
    {
        public Response GuardarTabla(string pathFile, HttpPostedFileBase file, TablaMigracion tablaMigracion, int currentUserId)
        {
            if (file == null)
            {
                return new Response()
                {
                    Value = false,
                    Message = "No existe archivo seleccionado"
                };
            }

            try
            {
                string fileName = pathFile + file.FileName;
                file.SaveAs(fileName);

                return GuardarEnRepositorio(fileName, tablaMigracion);
            }
            catch (Exception ex)
            {
                return new Response()
                {
                    Message = ex.Message
                };
            }
        }

        private Response GuardarEnRepositorio(string fileName, TablaMigracion tablaMigracion)
        {
            var result = new Response();
            using (var table = Table.Open(fileName))
            {
                //var dataTable = EstablecerEstructuraTabla(tablaMigracion);

                var reader = table.OpenReader(Encoding.ASCII);
                while (reader.Read())
                {
                    
                }
            }

            return result;
        }

        //private DataTable EstablecerEstructuraTabla(TablaMigracion tablaMigracion)
        //{
        //    var dataTable = new DataTable();

        //    foreach (var item in collection)
        //    {

        //    }
        //    return dataTable;
        //}


        //private List<string> Obtener()
    }
}
