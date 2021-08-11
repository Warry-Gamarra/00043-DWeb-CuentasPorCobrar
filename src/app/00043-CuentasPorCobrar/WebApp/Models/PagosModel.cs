using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Globalization;
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
        private IEstudianteService _estudianteService;

        public PagosModel()
        {
            _obligacionService = new ObligacionService();
            _estructuraArchivoModel = new EstructuraArchivoModel();
            procesoService = new ProcesoService();
            obligacionService = new ObligacionService();
            pagoService = new PagoService();
            _estudianteService = new EstudianteService();
        }

        public ImportacionPagoResponse CargarArchivoPagos(string serverPath, HttpPostedFileBase file, CargarArchivoViewModel model, int currentUserId)
        {
            if (file == null)
            {
                return new ImportacionPagoResponse()
                {
                    Message = "No existe archivo seleccionado."
                };
            }

            ImportacionPagoResponse response;
            string fileName = "";
            string filePathSaved = "";

            try
            {
                fileName = GenerarNombreArchivo(model.EntidadRecaudadora, file);
                filePathSaved = GuardarArchivoPagoEnHost(serverPath, fileName, model.TipoArchivo, file);

                List<PagoObligacionEntity> lstPagoObligaciones = LeerDetalleArchivoPagoObligaciones(filePathSaved, model.EntidadRecaudadora);

                if (lstPagoObligaciones != null)
                {
                    response = _obligacionService.Grabar_Pago_Obligaciones(lstPagoObligaciones, model.Observacion, currentUserId);
                }
                else
                {
                    response = new ImportacionPagoResponse() { Message = "No se encontró una estructura de columnas configuradas para el archivo" };
                }

                if (response.Success)
                {
                    GrabarHistorialCargaArchivo(lstPagoObligaciones.Count(), fileName, filePathSaved, currentUserId, 
                        model.EntidadRecaudadora, (int)TipoArchivoEntFinan.Recaudacion_Obligaciones);
                    ResponseModel.Success(response);
                }
                else
                {
                    EliminarArchivoHost(serverPath, fileName);
                    ResponseModel.Error(response);
                }
            }
            catch (Exception ex)
            {
                EliminarArchivoHost(serverPath, fileName);
                response = new ImportacionPagoResponse()
                {
                    Message = ex.Message
                };
                ResponseModel.Error(response);
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

            using (StreamReader file = new StreamReader(filePath))
            {
                while ((fileLine = file.ReadLine()) != null)
                {
                    linesFile.Add(fileLine);
                }
            }

            var result = new List<PagoObligacionEntity>();

            detalle.FilPosicionFin = detalle.FilPosicionFin == 0 ? linesFile.Count() : detalle.FilPosicionFin;

            var listaProcesos = procesoService.Listar_Procesos();

            for (int i = detalle.FilPosicionIni - 1; i < detalle.FilPosicionFin; i++)
            {
                string line = linesFile[i];

                var pagoEntity = new PagoObligacionEntity()
                {
                    B_Correcto = true,
                    T_ErrorMessage = String.Empty
                };

                pagoEntity.C_CodOperacion = line.Substring(columnas["C_CodOperacion"].Inicial - 1, columnas["C_CodOperacion"].Final - columnas["C_CodOperacion"].Inicial + 1).Trim();

                pagoEntity.T_NomDepositante = line.Substring(columnas["T_NomDepositante"].Inicial - 1, columnas["T_NomDepositante"].Final - columnas["T_NomDepositante"].Inicial + 1).Trim();

                pagoEntity.C_Referencia = line.Substring(columnas["C_Referencia"].Inicial - 1, columnas["C_Referencia"].Final - columnas["C_Referencia"].Inicial + 1).Trim();

                string sFechaPago = line.Substring(columnas["D_FecPago"].Inicial - 1, columnas["D_FecPago"].Final - columnas["D_FecPago"].Inicial + 1);

                string sHoraPago = line.Substring(columnas["D_HoraPago"].Inicial - 1, columnas["D_HoraPago"].Final - columnas["D_HoraPago"].Inicial + 1);

                try
                {
                    pagoEntity.D_FecPago = DateTime.ParseExact(sFechaPago + sHoraPago, FormatosDateTime.PAYMENT_DATETIME_FORMAT, CultureInfo.InvariantCulture);
                }
                catch (Exception ex)
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = ex.Message;
                }

                string sCantidad = line.Substring(columnas["I_Cantidad"].Inicial - 1, columnas["I_Cantidad"].Final - columnas["I_Cantidad"].Inicial + 1);

                try
                {
                    pagoEntity.I_Cantidad = sCantidad.Length == 0 ? 1 : int.Parse(sCantidad);
                }
                catch (Exception ex)
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = ex.Message;
                }
                
                pagoEntity.C_Moneda = line.Substring(columnas["C_Moneda"].Inicial - 1, columnas["C_Moneda"].Final - columnas["C_Moneda"].Inicial + 1).Trim();

                string sInteresMora = line.Substring(columnas["I_InteresMora"].Inicial - 1, columnas["I_MontoPago"].Final - columnas["I_MontoPago"].Inicial + 1);

                try
                {
                    pagoEntity.I_InteresMora = sInteresMora.Length == 0 ? 0 : decimal.Parse(sInteresMora) / 100;
                }
                catch (Exception ex)
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = ex.Message;
                }

                string montoPago = line.Substring(columnas["I_MontoPago"].Inicial - 1, columnas["I_MontoPago"].Final - columnas["I_MontoPago"].Inicial + 1);

                try
                {
                    pagoEntity.I_MontoPago = (decimal.Parse(montoPago) / 100) - pagoEntity.I_InteresMora;
                }
                catch (Exception ex)
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = ex.Message;
                }

                pagoEntity.T_LugarPago = line.Substring(columnas["T_LugarPago"].Inicial - 1, columnas["T_LugarPago"].Final - columnas["T_LugarPago"].Inicial + 1).Trim();

                pagoEntity.C_CodAlu = line.Substring(columnas["C_CodAlu"].Inicial - 1, columnas["C_CodAlu"].Final - columnas["C_CodAlu"].Inicial + 1).Trim();

                if (pagoEntity.T_NomDepositante.Length == 0 && pagoEntity.C_CodAlu.Length > 0)
                {
                    pagoEntity.T_NomDepositante = _estudianteService.GetNombresCompletos(pagoEntity.C_CodAlu);
                }

                pagoEntity.C_CodRc = line.Substring(columnas["C_CodRc"].Inicial - 1, columnas["C_CodRc"].Final - columnas["C_CodRc"].Inicial + 1).Trim();

                try
                {
                    pagoEntity.I_ProcesoID = int.Parse(line.Substring(columnas["I_ProcesoID"].Inicial - 1, columnas["I_ProcesoID"].Final - columnas["I_ProcesoID"].Inicial + 1));

                    pagoEntity.T_ProcesoDesc = listaProcesos.FirstOrDefault(x => x.I_ProcesoID == pagoEntity.I_ProcesoID).T_ProcesoDesc;
                }
                catch (Exception ex)
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = ex.Message;
                }

                string sFechaVcto = line.Substring(columnas["D_FecVencto"].Inicial - 1, columnas["D_FecVencto"].Final - columnas["D_FecVencto"].Inicial + 1);

                try
                {
                    pagoEntity.D_FecVencto = DateTime.ParseExact(sFechaVcto, "yyyyMMdd", CultureInfo.InvariantCulture);
                }
                catch (Exception ex)
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = ex.Message;
                }
                                
                pagoEntity.I_EntidadFinanID = entFinanId;

                pagoEntity.C_Extorno = line.Substring(columnas["C_Extorno"].Inicial - 1, columnas["C_Extorno"].Final - columnas["C_Extorno"].Inicial + 1).Trim();
                
                if (pagoEntity.B_Correcto && pagoEntity.I_EntidadFinanID.Equals(Bancos.BCP_ID) && pagoEntity.C_Extorno.Equals(ConstantesBCP.CodExtorno))
                {
                    pagoEntity.B_Correcto = false;
                    pagoEntity.T_ErrorMessage = "Pago extornado";
                }

                pagoEntity.T_InformacionAdicional = line.Substring(columnas["T_InformacionAdicional"].Inicial - 1, columnas["T_InformacionAdicional"].Final - columnas["T_InformacionAdicional"].Inicial + 1);

                result.Add(pagoEntity);
            }

            return result;
        }

        private void GrabarHistorialCargaArchivo(int cantFilas, string fileName, string urlPath, int currentUserId, int entidadFinanID, int tipoArchivoID)
        {
            pagoService.GrabarRegistroArchivo(fileName, urlPath, cantFilas, entidadFinanID, tipoArchivoID, currentUserId);
        }

        public ImportacionPagoResponse GrabarPagoObligacion(PagoObligacionViewModel model, int currentUserId)
        {
            var response = new ImportacionPagoResponse();

            var lista = new List<PagoObligacionEntity>();

            var obligacionAluCab = obligacionService.Obtener_ObligacionAluCab(model.idOligacionCab);

            if (obligacionAluCab != null)
            {
                if (obligacionAluCab.B_Pagado.Value)
                {
                    ResponseModel.Info(response, "La obligación seleccionada ya ha sido pagada.");

                    return response;
                }

                if (pagoService.ValidarCodOperacion(model.codigoOperacion, model.codigoAlumno, model.idEntidadFinanciera, model.fechaPagoObl))
                {
                    var entity = Mapper.PagoObligacionViewModel_To_PagoObligacionEntity(model);

                    entity.I_MontoPago = obligacionAluCab.I_MontoOblig.Value;

                    entity.I_ProcesoID = obligacionAluCab.I_ProcesoID.Value;

                    entity.D_FecVencto = obligacionAluCab.D_FecVencto.Value;

                    entity.B_Correcto = true;

                    lista.Add(entity);

                    response = _obligacionService.Grabar_Pago_Obligaciones(lista, model.observacion, currentUserId);

                    ResponseModel.Success(response, true);

                    return response;
                }
                else
                {
                    ResponseModel.Error(response, "El código de operación se encuentra repetido en el sistema.");

                    return response;
                }
            }
            else
            {
                ResponseModel.Error(response, "No se encuentra información acerca de la obligación seleccionada.");

                return response;
            }
        }

        public Response GrabarPagoTasa(PagoTasaViewModel model, int currentUserId)
        {
            throw new Exception();
        }


        public List<DatosPagoViewModel> ListarPagosRegistrados(DateTime? fecIni = null, DateTime? fecFin = null, int? dependenciaId = null, int? entRecaudaId = null)
        {
            var result = new List<DatosPagoViewModel>();

            foreach (var item in pagoService.ListarPagosRegistrados(fecIni, fecFin, dependenciaId, entRecaudaId))
            {
                result.Add(new DatosPagoViewModel(item));
            }

            return result;
        }

        public DatosPagoViewModel ObtenerDatosPago(int pagoProcesId)
        {
            return new DatosPagoViewModel(pagoService.ObtenerDatosPago(pagoProcesId));
        }

        public List<DatosPagoViewModel> BuscarPagoRegistrado(int entidadRecaudadoraId, string codOperacion)
        {
            var result = new List<DatosPagoViewModel>();

            foreach (var item in pagoService.BuscarPagoRegistrado(entidadRecaudadoraId, codOperacion))
            {
                result.Add(new DatosPagoViewModel(item));
            }
            return result;
        }


        public Response GrabarNroSiafPago(DatosPagoViewModel model, int currentUserId)
        {
            Response result = pagoService.GrabarNroSiafPago(model.PagoId, model.NroSIAF.Value, currentUserId, DateTime.Now);

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(false);
            }

            return result;
        }

        public Response GrabarNroSiafPago(int[] pagosProcesId, int nroSiaf, int currentUserId)
        {
            var result = new Response() { Value = true };
            int failsResult = 0;
            string errors = "";
            for (int i = 0; i < pagosProcesId.Count(); i++)
            {
                var partialResult = pagoService.GrabarNroSiafPago(pagosProcesId[i], nroSiaf, currentUserId, DateTime.Now);

                if (!partialResult.Value)
                {
                    var pago = ObtenerDatosPago(pagosProcesId[i]);
                    errors += $"• No se pudo actualizar el Nro SIAF para el pago {pago.CodOperacion} proveniente de { pago.EntidadRecaudadora }.\n";

                    failsResult++;
                }
            }

            if (failsResult> 0)
            {
                result.Value = false;
                result.Message = errors; 
                result.Error(false);
            }

            return result;
        }


        public Response AnularRegistroPago(int pagoProcesId, int currentUserId)
        {
            Response result = pagoService.AnularRegistroPago(pagoProcesId, currentUserId, DateTime.Now);

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(false);
            }

            return result;
        }

        public IEnumerable<ArchivoImportadoViewModel> ListarArchivosCargados()
        {
            var lista = pagoService.ListarArchivosImportados(TipoArchivoEntFinan.Recaudacion_Obligaciones);

            var result = lista.Select(x => Mapper.ArchivoImportadoDTO_To_ArchivoImportadoViewModel(x));

            return result;
        }
    }
}
