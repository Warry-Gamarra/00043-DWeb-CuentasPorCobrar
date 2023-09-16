using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.ExceptionServices;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using Data;
using Data.Procedures;
using Data.Tables;
using Data.Types;
using Data.Views;
using Domain.Entities;
using Domain.Helpers;

namespace Domain.Services.Implementations
{
    public class TasaService : ITasaService
    {
        public IEnumerable<TasaDTO> listar_Tasas()
        {
            var lista = VW_Tasas.GetAll();

            IEnumerable<TasaDTO> result = null;

            if (lista != null)
            {
                result = lista.Select(t => Mapper.VW_Tasas_To_TasaDTO(t));
            }

            return result;
        }

        public ImportacionPagoResponse Grabar_Pago_Tasas(List<PagoTasaEntity> dataPagoTasas, string observacion, int currentUserID)
        {
            ImportacionPagoResponse result;

            var grabarPago = new USP_I_GrabarPagoTasas()
            {
                UserID = currentUserID
            };

            try
            {
                var dataTable = Mapper.PagoTasaEntity_To_DataTable(dataPagoTasas.Where(x => x.B_Correcto).ToList());

                var spResult = grabarPago.Execute(dataTable, observacion, currentUserID).ToList();

                var pagosObservados = dataPagoTasas.Where(x => !x.B_Correcto)
                    .Select(x => new DataPagoTasasResult()
                    {
                        C_CodDepositante = x.C_CodDepositante,
                        T_NomDepositante = x.T_NomDepositante,
                        C_CodTasa = x.C_CodTasa,
                        T_TasaDesc = x.T_TasaDesc,
                        C_CodOperacion = x.C_CodOperacion,
                        C_Referencia = x.C_CodOperacion,
                        I_EntidadFinanID = x.I_EntidadFinanID,
                        I_CtaDepositoID = x.I_CtaDepositoID,
                        D_FecPago = x.D_FecPago,
                        I_Cantidad = x.I_Cantidad,
                        C_Moneda = x.C_Moneda,
                        I_MontoPago = x.I_MontoPago,
                        I_InteresMora = x.I_InteresMora,
                        T_LugarPago = x.T_LugarPago,
                        T_InformacionAdicional = x.T_InformacionAdicional,
                        B_Success = false,
                        T_ErrorMessage = x.T_ErrorMessage,
                        C_CodigoInterno = x.C_CodigoInterno,
                        T_SourceFileName = x.T_SourceFileName,
                        C_Extorno = x.C_Extorno,
                        C_CodServicio = x.C_CodServicio
                    });

                spResult.AddRange(pagosObservados);

                result = new ImportacionPagoResponse(spResult);
            }
            catch (Exception ex)
            {
                result = new ImportacionPagoResponse()
                {
                    Success = false,
                    Message = ex.Message
                };
            }

            return result;
        }

        public IEnumerable<PagoTasaDTO> Listar_Pago_Tasas(int? idEntidadFinanciera, int? idCtaDeposito, string codOperacion, DateTime? fechaInicio, DateTime? fechaFinal,
            string codDepositante, string nomDepositante, string codInterno)
        {
            var pagoTasas = VW_PagoTasas.GetAll(idEntidadFinanciera, idCtaDeposito, codOperacion, fechaInicio, fechaFinal, 
                codDepositante, nomDepositante, codInterno);

            var result = pagoTasas.Select(x => Mapper.VW_PagoTasas_To_PagoTasaDTO(x));

            return result;
        }

        public PagoTasaDTO ObtenerPagoTasa(int I_PagoBancoID)
        {
            var vw = VW_PagoTasas.FindByID(I_PagoBancoID);

            if (vw != null)
            {
                return Mapper.VW_PagoTasas_To_PagoTasaDTO(vw);
            }

            return null;
        }

        public Response Grabar_TasaUnfv(TasaEntity tasaEntity, SaveOption saveOption, int[] ctasDepositoServicio)
        {
            ResponseData result;

            int currentUserID = 0;

            switch (saveOption)
            {
                case SaveOption.Insert:

                    if (VW_Tasas.GetAll().FirstOrDefault(x => x.I_TasaUnfvID == tasaEntity.I_TasaUnfvID) != null)
                    {
                        return new Response() { Value = false, Message = "La tasa ya se encuentra registrada" };
                    }

                    if (CodServicioDuplicado(ctasDepositoServicio))
                    {
                        return new Response() { Value = false, Message = "Código de Servicio seleccionado 2 veces." };
                    }

                    var nuevaTasaUnfv = new USP_I_GrabarTasaUnfv()
                    {
                        I_ConceptoID = tasaEntity.I_ConceptoID,
                        T_ConceptoPagoDesc = tasaEntity.T_ConceptoPagoDesc,
                        B_Fraccionable = tasaEntity.B_Fraccionable,
                        B_ConceptoGeneral = tasaEntity.B_ConceptoGeneral,
                        B_AgrupaConcepto = tasaEntity.B_AgrupaConcepto,
                        I_AlumnosDestino = tasaEntity.I_AlumnosDestino,
                        I_GradoDestino = tasaEntity.I_GradoDestino,
                        I_TipoObligacion = tasaEntity.I_TipoObligacion,
                        T_Clasificador = tasaEntity.T_Clasificador,
                        C_CodTasa = tasaEntity.C_CodTasa,
                        B_Calculado = tasaEntity.B_Calculado,
                        I_Calculado = tasaEntity.I_Calculado,
                        B_AnioPeriodo = tasaEntity.B_AnioPeriodo,
                        I_Anio = tasaEntity.I_Anio,
                        I_Periodo = tasaEntity.I_Periodo,
                        B_Especialidad = tasaEntity.B_Especialidad,
                        C_CodRc = tasaEntity.C_CodRc,
                        B_Dependencia = tasaEntity.B_Dependencia,
                        C_DepCod = tasaEntity.C_DepCod,
                        B_GrupoCodRc = tasaEntity.B_GrupoCodRc,
                        I_GrupoCodRc = tasaEntity.I_GrupoCodRc,
                        B_ModalidadIngreso = tasaEntity.B_ModalidadIngreso,
                        I_ModalidadIngresoID = tasaEntity.I_ModalidadIngresoID,
                        B_ConceptoAgrupa = tasaEntity.B_ConceptoAgrupa,
                        I_ConceptoAgrupaID = tasaEntity.I_ConceptoAgrupaID,
                        B_ConceptoAfecta = tasaEntity.B_ConceptoAfecta,
                        I_ConceptoAfectaID = tasaEntity.I_ConceptoAfectaID,
                        N_NroPagos = tasaEntity.N_NroPagos,
                        B_Porcentaje = tasaEntity.B_Porcentaje,
                        C_Moneda = tasaEntity.C_Moneda,
                        M_Monto = tasaEntity.M_Monto,
                        M_MontoMinimo = tasaEntity.M_MontoMinimo,
                        T_DescripcionLarga = tasaEntity.T_DescripcionLarga,
                        T_Documento = tasaEntity.T_Documento,
                        I_UsuarioCre = tasaEntity.I_UsuarioCre.GetValueOrDefault(),
                    };

                    currentUserID = tasaEntity.I_UsuarioCre.GetValueOrDefault();

                    result = USP_I_GrabarTasaUnfv.Execute(nuevaTasaUnfv);

                    break;

                case SaveOption.Update:
                    if (CodServicioDuplicado(ctasDepositoServicio))
                    {
                        return new Response() { Value = false, Message = "Código de Servicio seleccionado 2 veces." };
                    }

                    var tasaUnfvActualizada = new USP_U_ActualizarTasaUnfv()
                    {
                        I_TasaUnfvID = tasaEntity.I_TasaUnfvID,
                        I_ConceptoID = tasaEntity.I_ConceptoID,
                        T_ConceptoPagoDesc = tasaEntity.T_ConceptoPagoDesc,
                        B_Fraccionable = tasaEntity.B_Fraccionable,
                        B_ConceptoGeneral = tasaEntity.B_ConceptoGeneral,
                        B_AgrupaConcepto = tasaEntity.B_AgrupaConcepto,
                        I_AlumnosDestino = tasaEntity.I_AlumnosDestino,
                        I_GradoDestino = tasaEntity.I_GradoDestino,
                        I_TipoObligacion = tasaEntity.I_TipoObligacion,
                        T_Clasificador = tasaEntity.T_Clasificador,
                        C_CodTasa = tasaEntity.C_CodTasa,
                        B_Calculado = tasaEntity.B_Calculado,
                        I_Calculado = tasaEntity.I_Calculado,
                        B_AnioPeriodo = tasaEntity.B_AnioPeriodo,
                        I_Anio = tasaEntity.I_Anio,
                        I_Periodo = tasaEntity.I_Periodo,
                        B_Especialidad = tasaEntity.B_Especialidad,
                        C_CodRc = tasaEntity.C_CodRc,
                        B_Dependencia = tasaEntity.B_Dependencia,
                        C_DepCod = tasaEntity.C_DepCod,
                        B_GrupoCodRc = tasaEntity.B_GrupoCodRc,
                        I_GrupoCodRc = tasaEntity.I_GrupoCodRc,
                        B_ModalidadIngreso = tasaEntity.B_ModalidadIngreso,
                        I_ModalidadIngresoID = tasaEntity.I_ModalidadIngresoID,
                        B_ConceptoAgrupa = tasaEntity.B_ConceptoAgrupa,
                        I_ConceptoAgrupaID = tasaEntity.I_ConceptoAgrupaID,
                        B_ConceptoAfecta = tasaEntity.B_ConceptoAfecta,
                        I_ConceptoAfectaID = tasaEntity.I_ConceptoAfectaID,
                        N_NroPagos = tasaEntity.N_NroPagos,
                        B_Porcentaje = tasaEntity.B_Porcentaje,
                        C_Moneda = tasaEntity.C_Moneda,
                        M_Monto = tasaEntity.M_Monto,
                        M_MontoMinimo = tasaEntity.M_MontoMinimo,
                        T_DescripcionLarga = tasaEntity.T_DescripcionLarga,
                        T_Documento = tasaEntity.T_Documento,
                        I_UsuarioMod = tasaEntity.I_UsuarioMod.GetValueOrDefault(),
                    };

                    currentUserID = tasaEntity.I_UsuarioMod.GetValueOrDefault();

                    result = USP_U_ActualizarTasaUnfv.Execute(tasaUnfvActualizada);

                    break;

                default:
                    result = new ResponseData()
                    {
                        Value = false,
                        Message = "Acción no válida."
                    };

                    break;
            }

            tasaEntity.I_TasaUnfvID = int.Parse(result.CurrentID);

            if (result.Value)
            {
                TI_TasaUnfv_CtaDepoServicio.DeshabilitarPorTasa(tasaEntity.I_TasaUnfvID, currentUserID);

                if (ctasDepositoServicio != null && ctasDepositoServicio.Count() > 0)
                {
                    var listaTasaCtaDepositoServicio = TI_TasaUnfv_CtaDepoServicio.GetAll();

                    foreach (var ctaDepositoServicioID in ctasDepositoServicio)
                    {
                        if (listaTasaCtaDepositoServicio.Any(x => x.I_CtaDepoServicioID == ctaDepositoServicioID && x.I_TasaUnfvID == tasaEntity.I_TasaUnfvID))
                        {
                            var tasaCtaDepositoServicio = listaTasaCtaDepositoServicio.First(x => x.I_CtaDepoServicioID == ctaDepositoServicioID && x.I_TasaUnfvID == tasaEntity.I_TasaUnfvID);

                            TI_TasaUnfv_CtaDepoServicio.CambiarEstado(tasaCtaDepositoServicio.I_TasaCtaDepoServicioID, true, currentUserID);
                        }
                        else
                        {
                            TI_TasaUnfv_CtaDepoServicio.Insert(ctaDepositoServicioID, tasaEntity.I_TasaUnfvID, currentUserID);
                        }
                    }
                }
            }

            return new Response(result);
        }

        public TasaEntity ObtenerTasaUnfv(int id)
        {
            try
            {
                var tasa = TI_TasaUnfv.FindByID(id);

                var result = new TasaEntity()
                {
                    I_TasaUnfvID = tasa.I_TasaUnfvID,
                    I_ConceptoID = tasa.I_ConceptoID,
                    T_ConceptoPagoDesc = tasa.T_ConceptoPagoDesc,
                    B_Fraccionable = tasa.B_Fraccionable,
                    B_ConceptoGeneral = tasa.B_ConceptoGeneral,
                    B_AgrupaConcepto = tasa.B_AgrupaConcepto,
                    I_AlumnosDestino = tasa.I_AlumnosDestino,
                    I_GradoDestino = tasa.I_GradoDestino,
                    I_TipoObligacion = tasa.I_TipoObligacion,
                    T_Clasificador = tasa.T_Clasificador,
                    C_CodTasa = tasa.C_CodTasa,
                    B_Calculado = tasa.B_Calculado,
                    I_Calculado = tasa.I_Calculado,
                    B_AnioPeriodo = tasa.B_AnioPeriodo,
                    I_Anio = tasa.I_Anio,
                    I_Periodo = tasa.I_Periodo,
                    B_Especialidad = tasa.B_Especialidad,
                    C_CodRc = tasa.C_CodRc,
                    B_Dependencia = tasa.B_Dependencia,
                    C_DepCod = tasa.C_DepCod,
                    B_GrupoCodRc = tasa.B_GrupoCodRc,
                    I_GrupoCodRc = tasa.I_GrupoCodRc,
                    B_ModalidadIngreso = tasa.B_ModalidadIngreso,
                    I_ModalidadIngresoID = tasa.I_ModalidadIngresoID,
                    B_ConceptoAgrupa = tasa.B_ConceptoAgrupa,
                    I_ConceptoAgrupaID = tasa.I_ConceptoAgrupaID,
                    B_ConceptoAfecta = tasa.B_ConceptoAfecta,
                    I_ConceptoAfectaID = tasa.I_ConceptoAfectaID,
                    N_NroPagos = tasa.N_NroPagos,
                    B_Porcentaje = tasa.B_Porcentaje,
                    C_Moneda = tasa.C_Moneda,
                    M_Monto = tasa.M_Monto,
                    M_MontoMinimo = tasa.M_MontoMinimo,
                    T_DescripcionLarga = tasa.T_DescripcionLarga,
                    T_Documento = tasa.T_Documento,
                    B_Habilitado = tasa.B_Habilitado,
                    B_Migrado = tasa.B_Migrado
                };

                return result;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public Response ChangeState(int tasaUnfvId, bool currentState, int currentUserId)
        {
            var tasa = new TI_TasaUnfv()
            {
                I_TasaUnfvID = tasaUnfvId,
                B_Habilitado = !currentState,
            };
            
            return new Response(tasa.ChangeState(currentUserId));
        }

        public int[] ObtenerCtaDepositoServicioIDs(int tasaUnfvID)
        {
            return TI_TasaUnfv_CtaDepoServicio.ObtenerCtaDepositoServicioIDByTasa(tasaUnfvID);
        }

        private bool CodServicioDuplicado(int[] ctasDepositoServicio)
        {
            bool existeError = false;

            if (ctasDepositoServicio != null && ctasDepositoServicio.Length > 0)
            {
                var listaServiciosSeleccionados = new List<int>();

                foreach (var ctaDepoServicioID in ctasDepositoServicio)
                {
                    var item = TI_CtaDepo_Servicio.FindByID(ctaDepoServicioID);

                    if (listaServiciosSeleccionados.Contains(item.I_ServicioID))
                    {
                        existeError = true;

                        break;
                    }

                    listaServiciosSeleccionados.Add(item.I_ServicioID);
                }
            }

            return existeError;
        }
    }
}
