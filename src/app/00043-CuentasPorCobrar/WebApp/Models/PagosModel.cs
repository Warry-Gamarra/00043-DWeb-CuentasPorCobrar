using DocumentFormat.OpenXml.Wordprocessing;
using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
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
        ITasaService tasaService;

        public PagosModel()
        {
            _obligacionService = new ObligacionService();
            _estructuraArchivoModel = new EstructuraArchivoModel();
            procesoService = new ProcesoService();
            obligacionService = new ObligacionService();
            pagoService = new PagoService();
            _estudianteService = new EstudianteService();
            tasaService = new TasaService();
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
            string sourceFileName = "";
            string filePathSaved = "";
            int cantFilasReg = 0;
            var tipoArchivo = TipoArchivoEntFinan.Recaudacion_Obligaciones;

            try
            {
                fileName = GenerarNombreArchivo(model.EntidadRecaudadora, file);
                sourceFileName = Path.GetFileNameWithoutExtension(file.FileName);
                filePathSaved = GuardarArchivoPagoEnHost(serverPath, fileName, model.TipoArchivo, file);

                switch (model.TipoArchivo)
                {
                    case TipoPago.Obligacion:
                        List<PagoObligacionEntity> lstPagoObligaciones = LeerDetalleArchivoPagoObligaciones(filePathSaved, sourceFileName, model.EntidadRecaudadora);

                        if (lstPagoObligaciones != null)
                        {
                            response = _obligacionService.Grabar_Pago_Obligaciones(lstPagoObligaciones, model.Observacion, currentUserId);

                            cantFilasReg = lstPagoObligaciones.Count();
                        }
                        else
                            response = new ImportacionPagoResponse() { Message = "No se encontró una estructura de columnas configuradas para el archivo." };

                        break;

                    case TipoPago.Tasa:

                        List<PagoTasaEntity> lstPagoTasas = LeerDetalleArchivoPagoTasas(filePathSaved, sourceFileName, model.EntidadRecaudadora);

                        if (lstPagoTasas != null)
                        {
                            response = tasaService.Grabar_Pago_Tasas(lstPagoTasas, model.Observacion, currentUserId);
                                                        
                            cantFilasReg = lstPagoTasas.Count();
                        }
                        else
                            response = new ImportacionPagoResponse() { Message = "No se encontró una estructura de columnas configuradas para el archivo." };

                        tipoArchivo = TipoArchivoEntFinan.Recaudacion_Tasas;

                        break;

                    default:
                        response = new ImportacionPagoResponse() { Message = "No se reconoce el tipo de archivo." };

                        break;
                }

                if (response.Success)
                {
                    GrabarHistorialCargaArchivo(cantFilasReg, fileName, filePathSaved, currentUserId,model.EntidadRecaudadora, (int)tipoArchivo);
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


        private List<PagoObligacionEntity> LeerDetalleArchivoPagoObligaciones(string filePath, string sourceFileName, int entFinanId)
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
                    I_CondicionPagoID = (int)CondicionPago.Correcto,
                    T_ErrorMessage = String.Empty,
                    I_EntidadFinanID = entFinanId,
                    T_SourceFileName = sourceFileName
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

                if (pagoEntity.I_EntidadFinanID.Equals(Bancos.BCP_ID))
                {
                    pagoEntity.C_Moneda = (pagoEntity.C_Moneda == "0") ? "PEN" : "USD";
                }
                else if (pagoEntity.I_EntidadFinanID.Equals(Bancos.BANCO_COMERCIO_ID))
                {
                    pagoEntity.C_Moneda = (pagoEntity.C_Moneda == "01") ? "PEN" : "USD";
                }

                string sInteresMora = line.Substring(columnas["I_InteresMora"].Inicial - 1, columnas["I_InteresMora"].Final - columnas["I_InteresMora"].Inicial + 1);

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

                pagoEntity.C_Extorno = line.Substring(columnas["C_Extorno"].Inicial - 1, columnas["C_Extorno"].Final - columnas["C_Extorno"].Inicial + 1).Trim();

                if (pagoEntity.B_Correcto && pagoEntity.I_EntidadFinanID.Equals(Bancos.BCP_ID) && pagoEntity.C_Extorno.Equals(ConstantesBCP.CodExtorno))
                {
                    pagoEntity.B_Correcto = true;
                    pagoEntity.I_CondicionPagoID = (int)CondicionPago.Extorno;
                    pagoEntity.T_ErrorMessage = "Pago extornado";
                }

                pagoEntity.T_InformacionAdicional = line.Substring(columnas["T_InformacionAdicional"].Inicial - 1, columnas["T_InformacionAdicional"].Final - columnas["T_InformacionAdicional"].Inicial + 1).Trim();

                pagoEntity.I_CondicionPagoID = pagoEntity.B_Correcto ? pagoEntity.I_CondicionPagoID : 0;

                pagoEntity.C_CodigoInterno = line.Substring(columnas["C_CodigoInterno"].Inicial - 1, columnas["C_CodigoInterno"].Final - columnas["C_CodigoInterno"].Inicial + 1).Trim();

                result.Add(pagoEntity);
            }

            return result;
        }

        private List<PagoTasaEntity> LeerDetalleArchivoPagoTasas(string filePath, string sourceFileName, int entFinanId)
        {
            string fileLine;
            List<string> linesFile = new List<string>();
            List<SeccionArchivoViewModel> estructuraArchivo = _estructuraArchivoModel.ObtenerEstructuraArchivo(entFinanId, TipoArchivoEntFinan.Recaudacion_Tasas);

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

            var result = new List<PagoTasaEntity>();

            detalle.FilPosicionFin = detalle.FilPosicionFin == 0 ? linesFile.Count() : detalle.FilPosicionFin;

            for (int i = detalle.FilPosicionIni - 1; i < detalle.FilPosicionFin; i++)
            {
                string line = linesFile[i];

                var pagoEntity = new PagoTasaEntity()
                {
                    B_Correcto = true,
                    T_ErrorMessage = String.Empty,
                    I_EntidadFinanID = entFinanId,
                    T_SourceFileName = sourceFileName
                };

                pagoEntity.C_CodDepositante = line.Substring(columnas["C_CodDepositante"].Inicial - 1, columnas["C_CodDepositante"].Final - columnas["C_CodDepositante"].Inicial + 1).Trim();

                pagoEntity.T_NomDepositante = line.Substring(columnas["T_NomDepositante"].Inicial - 1, columnas["T_NomDepositante"].Final - columnas["T_NomDepositante"].Inicial + 1).Trim();

                pagoEntity.C_CodServicio = line.Substring(columnas["C_CodServicio"].Inicial - 1, columnas["C_CodServicio"].Final - columnas["C_CodServicio"].Inicial + 1).Trim();

                pagoEntity.C_CodTasa = line.Substring(columnas["C_CodTasa"].Inicial - 1, columnas["C_CodTasa"].Final - columnas["C_CodTasa"].Inicial + 1).Trim();

                pagoEntity.T_TasaDesc = line.Substring(columnas["T_TasaDesc"].Inicial - 1, columnas["T_TasaDesc"].Final - columnas["T_TasaDesc"].Inicial + 1).Trim();

                pagoEntity.C_CodOperacion = line.Substring(columnas["C_CodOperacion"].Inicial - 1, columnas["C_CodOperacion"].Final - columnas["C_CodOperacion"].Inicial + 1).Trim();

                pagoEntity.T_Referencia = line.Substring(columnas["T_Referencia"].Inicial - 1, columnas["T_Referencia"].Final - columnas["T_Referencia"].Inicial + 1).Trim();

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

                if (pagoEntity.I_EntidadFinanID.Equals(Bancos.BCP_ID))
                {
                    pagoEntity.C_Moneda = (pagoEntity.C_Moneda == "0") ? "PEN" : "USD";
                }
                else if (pagoEntity.I_EntidadFinanID.Equals(Bancos.BANCO_COMERCIO_ID))
                {
                    pagoEntity.C_Moneda = (pagoEntity.C_Moneda == "01") ? "PEN" : "USD";
                }

                string sInteresMora = line.Substring(columnas["I_InteresMora"].Inicial - 1, columnas["I_InteresMora"].Final - columnas["I_InteresMora"].Inicial + 1);

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

                pagoEntity.T_InformacionAdicional = line.Substring(columnas["T_InformacionAdicional"].Inicial - 1, columnas["T_InformacionAdicional"].Final - columnas["T_InformacionAdicional"].Inicial + 1).Trim();

                pagoEntity.C_CodigoInterno = line.Substring(columnas["C_CodigoInterno"].Inicial - 1, columnas["C_CodigoInterno"].Final - columnas["C_CodigoInterno"].Inicial + 1).Trim();

                pagoEntity.C_Extorno = line.Substring(columnas["C_Extorno"].Inicial - 1, columnas["C_Extorno"].Final - columnas["C_Extorno"].Inicial + 1).Trim();

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

                if (pagoService.ValidarCodOperacionObligacion(model.codigoOperacion, model.codigoAlumno, model.idEntidadFinanciera, model.fechaPagoObl, obligacionAluCab.I_ProcesoID.Value, obligacionAluCab.D_FecVencto.Value))
                {
                    var entity = Mapper.PagoObligacionViewModel_To_PagoObligacionEntity(model);

                    entity.I_ProcesoID = obligacionAluCab.I_ProcesoID.Value;

                    entity.T_ProcesoDesc = procesoService.Obtener_Proceso(entity.I_ProcesoID).T_ProcesoDesc;

                    entity.D_FecVencto = obligacionAluCab.D_FecVencto.Value;

                    entity.B_Correcto = true;

                    entity.I_CondicionPagoID = (int)CondicionPago.Correcto;

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

        public ImportacionPagoResponse GrabarPagoTasa(PagoTasaViewModel model, int currentUserId)
        {
            var response = new ImportacionPagoResponse();

            var lista = new List<PagoTasaEntity>();

            if (pagoService.ValidarCodOperacionTasa(model.codigoOperacion, model.idEntidadFinanciera, model.fechaPagoTasa))
            {
                var tasa = tasaService.listar_Tasas().First(x => x.I_TasaUnfvID == model.tasa);

                var entity = Mapper.PagoTasaViewModel_To_PagoTasaEntity(model);

                entity.C_CodTasa = tasa.C_CodTasa;

                entity.T_TasaDesc = tasa.T_ConceptoPagoDesc;

                entity.B_Correcto = true;

                lista.Add(entity);

                response = tasaService.Grabar_Pago_Tasas(lista, model.observacion, currentUserId);

                ResponseModel.Success(response, true);

                return response;
            }
            else
            {
                ResponseModel.Error(response, "El código de operación se encuentra repetido en el sistema.");

                return response;
            }
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

        public DatosPagoViewModel ObtenerDatosPago(int pagoBancoId)
        {
            return new DatosPagoViewModel(pagoService.ObtenerDatosPago(pagoBancoId));
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

            if (failsResult > 0)
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

        public IEnumerable<ArchivoImportadoViewModel> ListarArchivosCargados(TipoArchivoEntFinan tipoArchivo)
        {
            var lista = pagoService.ListarArchivosImportados(tipoArchivo);

            var result = lista.Select(x => Mapper.ArchivoImportadoDTO_To_ArchivoImportadoViewModel(x));

            return result;
        }


        public MemoryStream ExportarInformacionTemporalPagos(int entRecaudaId, DateTime fecIni, DateTime fecFin, TipoEstudio? tipoEstudio, TipoPago tipoPago)
        {
            var memoryStream = new MemoryStream();
            var writer = new StreamWriter(memoryStream, Encoding.Default);

            var infoPagos = pagoService.ListarPagosRegistrados(fecIni, fecFin, tipoEstudio, entRecaudaId, tipoPago);


            #region Cabecera

            string codTipoRegistro = "T";
            string totalMontoSoles = Convert.ToInt64(infoPagos.Where(x => x.Moneda == "PEN").Sum(x => x.MontoPago * 100)).ToString().PadLeft(14, '0');
            string totalMontoDolares = Convert.ToInt64(infoPagos.Where(x => x.Moneda != "PEN").Sum(x => x.MontoPago * 100)).ToString().PadLeft(14, '0');
            string nroRegistrosSoles = infoPagos.Where(x => x.Moneda == "PEN").Count().ToString().PadLeft(6, '0');
            string nroRegistrosDolares = infoPagos.Where(x => x.Moneda != "PEN").Count().ToString().PadLeft(6, '0');
            string fechaEnvio = fecIni.ToString("yyyyMMdd");
            string fechaFin = fecFin.ToString("yyyyMMdd");
            string cadenaCabecera;

            cadenaCabecera = string.Format("{0}{1}{2}{3}{4}{5}", codTipoRegistro, nroRegistrosSoles, totalMontoSoles, nroRegistrosDolares, totalMontoDolares, fechaFin);
            writer.WriteLine(cadenaCabecera);

            #endregion

            if (nroRegistrosSoles.Length != 6)
            {
                throw new Exception("La cantidad de registros en el intervalo de fechas seleccionado sobrepasa los límites del archivo. Seleccione un intervalo menor de fechas");
            }

            #region Detalle
            string identificadorRegistroDetalle = "D";
            string codigoServicio;
            string codigoSucursal;
            string codAlu;
            string codOperacion;
            string referencia;
            string nroRecibo;
            string moneda;
            string fecPago;
            string fecEmision = "00000000";
            string fecVencto;
            string cantidad;
            string montoPago;
            string procesoID;
            string lugarPago;
            string agencia;
            string nomDepositante;
            string horaPago;
            string interesMora;
            string datosEntidad;
            string medioPago = "";
            string formaPago = "";
            string importeDescontdo = "0";
            string importeReajustado = "0";
            string codigoTarifa = "";
            string usuarioPago = "BCP";
            string referenciaPago = "";
            string cadenaDetalle = "";
            string informacionAdicional = "";

            foreach (var item in infoPagos)
            {
                fecVencto = item.FecVencto.ToString("yyyyMMdd");
                informacionAdicional = item.CodAlumno + item.CodRc + item.Anio + item.Periodo + item.FecVencto.Year.ToString() + item.FecVencto.Month.ToString().PadLeft(2, ' ') + 
                                       item.FecVencto.Day.ToString().PadLeft(2, ' ') + item.CuotaPago.ToString().PadLeft(10, ' ') + item.MontoPago.ToString("#.00").PadLeft(10, ' ');

                codigoServicio = item.CodServicio.PadRight(4, ' ');
                codigoSucursal = "".PadRight(3, ' ');
                codAlu = item.CodDepositante.PadLeft(10, '0').PadRight(20, ' ');
                codOperacion = item.CodOperacion.PadRight(20, ' ');
                nroRecibo = item.NroCuota.ToString("000000").PadRight(20, ' ');
                referencia = string.Empty.PadRight(20, ' ');
                referenciaPago = (entRecaudaId == 1 ? item.Referencia : item.CodOperacion).Substring2(0, 10).PadRight(10, ' ');
                moneda = item.Moneda == "PEN" ? "01" : "02";
                fecPago = item.FecPago.ToString("yyyyMMdd");
                cantidad = item.Cantidad.ToString();
                montoPago = Convert.ToInt32(item.MontoPago * 100).ToString().PadLeft(14, '0');
                procesoID = item.CuotaPago.ToString();
                nomDepositante = item.NomDepositante.Substring2(0, 40).PadRight(40, ' ');
                horaPago = item.FecPago.ToString("HHmmss");
                interesMora = 0.ToString().PadLeft(14, '0');
                datosEntidad = informacionAdicional.Substring2(0, 50).PadRight(50, ' ');
                codigoTarifa = codigoTarifa.PadRight(20, ' ');
                cantidad = item.Cantidad.ToString().PadLeft(4, '0');
                importeDescontdo = importeDescontdo.PadLeft(14, '0');
                importeReajustado = importeReajustado.PadLeft(14, '0');
                lugarPago = item.LugarPago.Substring2(0, 2);
                agencia = entRecaudaId == 1 ? item.LugarPago.Substring(2, 3) : item.LugarPago.Substring(3, 3);
                formaPago = entRecaudaId == 1 ? item.LugarPago.Substring2(5, 1) : "1";
                medioPago = entRecaudaId == 1 ? item.LugarPago.Substring2(6, 1) : "1";
                usuarioPago = usuarioPago.PadRight(10, ' ');


                cadenaDetalle = string.Format("{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}{13}{14}{15}{16}{17}{18}{19}{20}{21}{22}{23}{24}",
                    identificadorRegistroDetalle,
                    codigoServicio,
                    codigoSucursal,
                    codAlu,
                    nomDepositante,
                    nroRecibo,
                    referencia,
                    fecEmision,
                    fecVencto,
                    moneda,
                    montoPago,
                    datosEntidad,
                    interesMora,
                    fecPago,
                    horaPago,
                    lugarPago,
                    agencia,
                    medioPago,
                    formaPago,
                    importeDescontdo,
                    importeReajustado,
                    codigoTarifa,
                    cantidad,
                    usuarioPago,
                    referenciaPago);
                writer.WriteLine(cadenaDetalle);
            }

            #endregion

            writer.Flush();

            memoryStream.Seek(0, SeekOrigin.Begin);

            return memoryStream;
        }

        public IEnumerable<PagoBancoObligacionViewModel> ListarPagoBancoObligacion(ConsultaPagosBancoObligacionesViewModel parametro)
        {
            var lista = pagoService.ListarPagosBanco(parametro.banco, parametro.ctaDeposito, parametro.codOperacion, 
                parametro.codAlumno, parametro.fechaInicio, parametro.fechaFin, parametro.condicion,
                parametro.nomAlumno, parametro.apePaternoAlumno, parametro.apeMaternoAlumno, parametro.codInterno, parametro.tipoEstudio);

            var result = lista.Select(x => Mapper.PagoBancoObligacionDTO_ToPagoBancoObligacionViewModel(x));

            return result;
        }

        public IEnumerable<PagoBancoObligacionViewModel> ListarPagosBancoPorObligacion(int idObligacion)
        {
            var lista = pagoService.ListarPagosBancoPorObligacion(idObligacion);

            var result = lista.Select(x => Mapper.PagoBancoObligacionDTO_ToPagoBancoObligacionViewModel(x));

            return result;
        }

        public PagoBancoObligacionViewModel ObtenerPagoBanco(int idPagoBanco)
        {
            var pago = pagoService.ObtenerPagoBanco(idPagoBanco);

            return pago == null ? null : Mapper.PagoBancoObligacionDTO_ToPagoBancoObligacionViewModel(pago);
        }

        public Response AsignarPagoObligacion(int obligacionID, int pagoBancoID, int UserID, string motivoCoreccion)
        {
            Response result = pagoService.AsignarPagoObligacion(obligacionID, pagoBancoID, UserID, motivoCoreccion);

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

        public Response DesenlazarPagoObligacion(int pagoBancoID, int UserID, string motivoCoreccion)
        {
            Response result = pagoService.DesenlazarPagoObligacion(pagoBancoID, UserID, motivoCoreccion);

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

        public IEnumerable<PagoObligacionDetalleDTO> ObtenerPagoObligacionDetalle(int idObligacionDet)
        {
            return pagoService.ObtenerPagoObligacionDetalle(idObligacionDet);
        }

        public Response ActualizarPagoTasa(int I_PagoBancoID, string C_CodDepositante, int I_TasaUnfvId, int I_CurrentUserID)
        {
            Response result = pagoService.ActualizarPagoTasa(I_PagoBancoID, C_CodDepositante, I_TasaUnfvId, I_CurrentUserID);

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
    }
}
