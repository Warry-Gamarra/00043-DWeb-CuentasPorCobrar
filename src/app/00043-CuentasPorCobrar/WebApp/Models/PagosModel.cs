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
        private IProcesoService procesoService;
        private IObligacionService obligacionService;
        private IPagoService pagoService;

        public PagosModel()
        {
            _obligacionService = new ObligacionService();
            _estructuraArchivoModel = new EstructuraArchivoModel();
            procesoService = new ProcesoService();
            obligacionService = new ObligacionService();
            pagoService = new PagoService();
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
            string filePathSaved = "";

            try
            {
                fileName = GenerarNombreArchivo(model.EntidadRecaudadora, file);
                filePathSaved = GuardarArchivoPagoEnHost(serverPath, fileName, model.TipoArchivo, file);

                List<PagoObligacionEntity> lstPagoObligaciones = LeerDetalleArchivoPagoObligaciones(filePathSaved, model.EntidadRecaudadora);

                if (lstPagoObligaciones != null)
                {
                    response = _obligacionService.Grabar_Pago_Obligaciones(lstPagoObligaciones, currentUserId);
                }
                else
                {
                    response = new Response() { Message = "No se encontró una estructura de columnas configuradas para el archivo" };
                }

                if (response.Value)
                {

                    response.Success(false);
                }
                else
                {
                    EliminarArchivoHost(serverPath, fileName);
                    response.Error(false);
                }
            }
            catch (Exception ex)
            {
                EliminarArchivoHost(serverPath, fileName);
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }

        private string GenerarNombreArchivo(int entFinanId, HttpPostedFileBase file)
        {
            return entFinanId.ToString() + "_"
                    + Path.GetFileNameWithoutExtension(file.FileName) + "_"
                    + Guid.NewGuid() + Path.GetExtension(file.FileName);
        }

        private string GuardarArchivoPagoEnHost(string serverPath, string fileName, TipoPago tipoPago, HttpPostedFileBase file)
        {
            string filePath;
            try
            {
                switch (tipoPago)
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

                filePath = serverPath + fileName;

                file.SaveAs(filePath);

                return filePath;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        private void EliminarArchivoHost(string serverPath, string fileName)
        {
            File.Delete(serverPath + fileName);
        }

        private List<PagoObligacionEntity> LeerDetalleArchivoPagoObligaciones(string filePath, int entFinanId)
        {
            string fileLine;
            List<string> linesFile = new List<string>();
            List<SeccionArchivoViewModel> estructuraArchivo = _estructuraArchivoModel.ObtenerEstructuraArchivo(entFinanId, TipoArchivoEntFinan.Recaudacion_Obligaciones);

            if (estructuraArchivo.Count == 0)
            {
                return null;
            }

            var detalle = estructuraArchivo.Find(x => x.TipoSeccion == TipoSeccionArchivo.Detalle_Recaudacion);
            if (detalle == null)
            {
                return null;
            }

            var columnas = detalle.ColumnasSeccion.ToDictionary(x => x.CampoTablaNom, x => new Posicion { Inicial = x.ColPosicionIni, Final = x.ColPosicionFin });

            StreamReader file = new StreamReader(filePath);

            var result = new List<PagoObligacionEntity>();

            while ((fileLine = file.ReadLine()) != null)
            {
                linesFile.Add(fileLine);
            }

            detalle.FilPosicionFin = detalle.FilPosicionFin == 0 ? linesFile.Count() : detalle.FilPosicionFin;

            for (int i = detalle.FilPosicionIni - 1; i < detalle.FilPosicionFin; i++)
            {
                string line = linesFile[i];
                var pagoEntity = new PagoObligacionEntity();

                pagoEntity.C_CodOperacion = line.Substring(columnas["C_CodOperacion"].Inicial - 1, columnas["C_CodOperacion"].Final - 1);
                pagoEntity.T_NomDepositante = line.Substring(columnas["T_NomDepositante"].Inicial - 1, columnas["T_NomDepositante"].Final - 1);
                pagoEntity.C_Referencia = line.Substring(columnas["C_Referencia"].Inicial - 1, columnas["C_Referencia"].Final - 1);
                pagoEntity.D_FecPago = DateTime.Parse(line.Substring(columnas["D_FecPago"].Inicial - 1, columnas["D_FecPago"].Final - 1));
                pagoEntity.I_Cantidad = int.Parse(line.Substring(columnas["I_Cantidad"].Inicial - 1, columnas["I_Cantidad"].Final - 1));
                pagoEntity.C_Moneda = line.Substring(columnas["C_Moneda"].Inicial - 1, columnas["C_Moneda"].Final - 1);
                pagoEntity.I_MontoPago = decimal.Parse(line.Substring(columnas["I_MontoPago"].Inicial - 1, columnas["I_MontoPago"].Final - 1));
                pagoEntity.T_LugarPago = line.Substring(columnas["T_LugarPago"].Inicial - 1, columnas["T_LugarPago"].Final - 1);
                pagoEntity.C_CodAlu = line.Substring(columnas["C_CodAlu"].Inicial - 1, columnas["C_CodAlu"].Final - 1);
                pagoEntity.C_CodRc = line.Substring(columnas["C_CodRc"].Inicial - 1, columnas["C_CodRc"].Final - 1);
                pagoEntity.I_ProcesoID = int.Parse(line.Substring(columnas["I_ProcesoID"].Inicial - 1, columnas["I_ProcesoID"].Final - 1));
                pagoEntity.D_FecVencto = DateTime.Parse(line.Substring(columnas["D_FecVencto"].Inicial - 1, columnas["D_FecVencto"].Final - 1));

                result.Add(pagoEntity);
            }

            file.Dispose();

            return result;
        }


        private void GrabarHistorialCargaArchivo()
        {

        }


        public Response GrabarPagoObligacion(PagoObligacionViewModel model, int currentUserId)
        {
            var response = new Response();

            var lista = new List<PagoObligacionEntity>();

            var obligacionAluCab = obligacionService.Obtener_ObligacionAluCab(model.idOligacionCab);

            if (obligacionAluCab != null)
            {
                if (obligacionAluCab.B_Pagado.Value)
                {
                    return ResponseModel.Info(response, "La obligación seleccionada ya ha sido pagada.");
                }

                if (pagoService.ValidarCodOperacion(model.codigoOperacion, model.idEntidadFinanciera, model.fechaPago))
                {
                    var entity = Mapper.PagoObligacionViewModel_To_PagoObligacionEntity(model);

                    entity.I_MontoPago = obligacionAluCab.I_MontoOblig.Value;

                    entity.I_ProcesoID = obligacionAluCab.I_ProcesoID.Value;

                    entity.D_FecVencto = obligacionAluCab.D_FecVencto.Value;

                    lista.Add(entity);

                    response = _obligacionService.Grabar_Pago_Obligaciones(lista, currentUserId);

                    return ResponseModel.Success(response, true);
                }
                else
                {
                    return ResponseModel.Error(response, "El código de operación se encuentra repetido en el sistema.");
                }
            }
            else
            {
                return ResponseModel.Error(response, "No se encuentra información acerca de la obligación seleccionada.");
            }
        }

        public Response GrabarPagoTasa(PagoTasaViewModel model, int currentUserId)
        {
            throw new Exception();
        }
    }
}
