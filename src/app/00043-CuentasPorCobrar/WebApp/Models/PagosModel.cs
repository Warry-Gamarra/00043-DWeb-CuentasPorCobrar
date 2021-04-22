using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class PagosModel
    {
        private readonly ObligacionService _obligacionService;
        private readonly EstructuraArchivoModel _estructuraArchivoModel;

        public PagosModel()
        {
            _obligacionService = new ObligacionService();
        }

        public Response CargarArchivoPagos(string serverPath, HttpPostedFileBase file, CargarArchivoViewModel model, int currentUserId)
        {
            if (file == null)
            {
                return new Response()
                {
                    Message = "No existe archivo seleccionado."
                };
            }

            Response response;
            string fileName = "";

            switch (model.TipoArchivo)
            {
                case TipoPago.Obligacion:
                    serverPath += "Obligaciones/";
                    break;
                case TipoPago.Tasa:
                    serverPath += "Tasas/";
                    break;
                default:
                    break;
            }

            try
            {
                fileName = GuardarArchivoEnHost(serverPath, model.EntidadFinanciera, file);

                response = GuardarDatosObligaciones(serverPath + fileName, model.EntidadFinanciera, currentUserId);
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }

        private string GuardarArchivoEnHost(string serverPath, int entFinanId, HttpPostedFileBase file)
        {
            try
            {
                string fileName = entFinanId.ToString() + "_" 
                                  + Path.GetFileNameWithoutExtension(file.FileName) + "_" 
                                  + Guid.NewGuid() + Path.GetExtension(file.FileName);

                file.SaveAs(serverPath + fileName);

                return fileName;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private Response GuardarDatosObligaciones(string filePath, int entFinanId, int currentUserId)
        {
            var result = new Response();
            var lista = LeerEstructuraArchivoPagoObligaciones(filePath, entFinanId);
            return result;
        }


        private List<PagoObligacionEntity> LeerEstructuraArchivoPagoObligaciones(string filePath, int entFinanId)
        {
            string line;
            int fila = 0;
            List<SeccionArchivoViewModel> estructuraArchivo = _estructuraArchivoModel.ObtenerEstructuraArchivo(entFinanId, TipoArchivoEntFinan.Recaudacion_Obligaciones);

            if (estructuraArchivo.Count == 0)
            {
                return null;
            }

            var detalle = estructuraArchivo[1];
            var columnas = detalle.ColumnasSeccion;

            var col_CodOperacion = columnas.FirstOrDefault(x => x.CampoTablaNom == "C_CodOperacion");
            var col_NomDepositante = columnas.FirstOrDefault(x => x.CampoTablaNom == "T_NomDepositante");
            var col_Referencia = columnas.FirstOrDefault(x => x.CampoTablaNom == "C_Referencia");
            var col_FecPago = columnas.FirstOrDefault(x => x.CampoTablaNom == "D_FecPago");
            var col_Cantidad = columnas.FirstOrDefault(x => x.CampoTablaNom == "I_Cantidad");
            var col_Moneda = columnas.FirstOrDefault(x => x.CampoTablaNom == "C_Moneda");
            var col_MontoPago = columnas.FirstOrDefault(x => x.CampoTablaNom == "I_MontoPago");
            var col_LugarPago = columnas.FirstOrDefault(x => x.CampoTablaNom == "T_LugarPago");
            var col_CodAlu = columnas.FirstOrDefault(x => x.CampoTablaNom == "C_CodDepositante");
            var col_CodRc = columnas.FirstOrDefault(x => x.CampoTablaNom == "C_CodRc");
            var col_ProcesoID = columnas.FirstOrDefault(x => x.CampoTablaNom == "I_ProcesoID");
            var col_FecVencto = columnas.FirstOrDefault(x => x.CampoTablaNom == "D_FecVencto");

            StreamReader file = new StreamReader(filePath);

            var result = new List<PagoObligacionEntity>();

            while ((line = file.ReadLine()) != null)
            {
                fila++;
                if (detalle.FilPosicionIni <= fila && (fila <= detalle.FilPosicionFin || detalle.FilPosicionFin == 0))
                {
                    var pagoEntity = new PagoObligacionEntity();

                    pagoEntity.C_CodOperacion = line.Substring(col_CodOperacion.ColPosicionIni - 1, col_CodOperacion.ColPosicionFin - 1);
                    pagoEntity.T_NomDepositante = line.Substring(col_NomDepositante.ColPosicionIni - 1, col_NomDepositante.ColPosicionFin - 1);
                    pagoEntity.C_Referencia = line.Substring(col_Referencia.ColPosicionIni - 1, col_Referencia.ColPosicionFin - 1);
                    pagoEntity.D_FecPago = DateTime.Parse(line.Substring(col_FecPago.ColPosicionIni - 1, col_FecPago.ColPosicionFin - 1));
                    pagoEntity.I_Cantidad = int.Parse(line.Substring(col_Cantidad.ColPosicionIni - 1, col_Cantidad.ColPosicionFin - 1));
                    pagoEntity.C_Moneda = line.Substring(col_Moneda.ColPosicionIni - 1, col_Moneda.ColPosicionFin - 1);
                    pagoEntity.I_MontoPago = decimal.Parse(line.Substring(col_MontoPago.ColPosicionIni - 1, col_MontoPago.ColPosicionFin - 1));
                    pagoEntity.T_LugarPago = line.Substring(col_LugarPago.ColPosicionIni - 1, col_LugarPago.ColPosicionFin - 1);
                    pagoEntity.C_CodAlu = line.Substring(col_CodAlu.ColPosicionIni - 1, col_CodAlu.ColPosicionFin - 1);
                    pagoEntity.C_CodRc = line.Substring(col_CodRc.ColPosicionIni - 1, col_CodRc.ColPosicionFin - 1);
                    pagoEntity.I_ProcesoID = int.Parse(line.Substring(col_ProcesoID.ColPosicionIni - 1, col_ProcesoID.ColPosicionFin - 1));
                    pagoEntity.D_FecVencto = DateTime.Parse(line.Substring(col_FecVencto.ColPosicionIni - 1, col_FecVencto.ColPosicionFin - 1));
                }
            }

            return result;
        }

    }
}