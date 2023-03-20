using Domain.Entities;
using Domain.Helpers;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class TasaServiceFacade : ITasaServiceFacade
    {
        ITasaService tasaService;

        public TasaServiceFacade()
        {
            tasaService = new TasaService();
        }

        public IEnumerable<SelectViewModel> listarTasas()
        {
            var lista = tasaService.listar_Tasas();

            IEnumerable<SelectViewModel> result = null;

            if (lista != null)
            {
                result = lista.Where(t => t.B_Habilitado).Select(t => new SelectViewModel()
                {
                    Value = t.I_TasaUnfvID.ToString(),
                    TextDisplay = String.Format("{0} - {1} (S/. {2})", t.C_CodTasa, t.T_ConceptoPagoDesc, t.I_MontoTasa)
                });
            }

            return result;
        }

        public IEnumerable<TasaViewModel> listarTodoTasas()
        {
            var lista = tasaService.listar_Tasas();

            IEnumerable<TasaViewModel> result = null;

            if (lista != null)
            {
                result = lista.Select(t => new TasaViewModel()
                {
                    I_TasaUnfvID = t.I_TasaUnfvID,
                    C_CodTasa = t.C_CodTasa,
                    T_clasificador = t.T_clasificador,
                    T_ConceptoPagoDesc = t.T_ConceptoPagoDesc,
                    I_MontoTasa = t.I_MontoTasa,
                    B_Habilitado = t.B_Habilitado
                });
            }

            return result;
        }

        public IEnumerable<PagoTasaModel> listarPagoTasas(ConsultaPagoTasasViewModel model)
        {
            var lista = tasaService.Listar_Pago_Tasas(model.entidadFinanciera, model.idCtaDeposito, model.codOperacion,
                model.fechaInicio, model.fechaFin, model.codDepositante, model.nomDepositante, model.codInterno);

            var result = lista.Select(x => Mapper.PagoTasaDTO_To_PagoTasaModel(x));

            return result;
        }

        public PagoTasaModel ObtenerPagoTasa(int I_PagoBancoID)
        {
            var dto = tasaService.ObtenerPagoTasa(I_PagoBancoID);

            if (dto != null)
            {
                return Mapper.PagoTasaDTO_To_PagoTasaModel(dto);
            }

            return null;
        }

        public Response Grabar_TasaUnfv(RegistrarTasaViewModel model, int currentUserId)
        {
            TasaEntity tasaEntity;
            Response result;

            var saveOption = (!model.I_TasaUnfvID.HasValue) ? SaveOption.Insert : SaveOption.Update;

            var lista = tasaService.listar_Tasas();

            if (saveOption.Equals(SaveOption.Insert))
            {
                if (lista.FirstOrDefault(t => t.B_Habilitado && t.C_CodTasa == model.C_CodTasa) != null)
                {
                    result = new Response()
                    {
                        Value = false,
                        Message = "El Código de Tasa se encuentra duplicado."
                    };

                    return result.Error(false);
                }
            }
            else if(saveOption.Equals(SaveOption.Update))
            {
                if (lista.FirstOrDefault(t => t.B_Habilitado && t.C_CodTasa == model.C_CodTasa && t.I_TasaUnfvID != model.I_TasaUnfvID) != null)
                {
                    result = new Response()
                    {
                        Value = false,
                        Message = "El Código de Tasa se encuentra duplicado."
                    };

                    return result.Error(false);
                }
            } 


            tasaEntity = new TasaEntity()
            {
                I_TasaUnfvID = model.I_TasaUnfvID.GetValueOrDefault(),
                I_ConceptoID = model.I_ConceptoID,
                T_ConceptoPagoDesc = model.T_ConceptoPagoDesc.ToUpper(),
                B_Fraccionable = model.B_Fraccionable,
                B_ConceptoGeneral = model.B_ConceptoGeneral,
                B_AgrupaConcepto = model.B_AgrupaConcepto,
                I_AlumnosDestino = model.I_AlumnosDestino,
                I_GradoDestino = model.I_GradoDestino,
                I_TipoObligacion = model.I_TipoObligacion,
                T_Clasificador = model.T_Clasificador,
                C_CodTasa = model.C_CodTasa,
                B_Calculado = model.B_Calculado,
                I_Calculado = model.I_Calculado,
                B_AnioPeriodo = model.B_AnioPeriodo,
                I_Anio = model.I_Anio,
                I_Periodo = model.I_Periodo,
                B_Especialidad = model.B_Especialidad,
                C_CodRc = model.C_CodRc,
                B_Dependencia = model.B_Dependencia,
                C_DepCod = model.C_DepCod,
                B_GrupoCodRc = model.B_GrupoCodRc,
                I_GrupoCodRc = model.I_GrupoCodRc,
                B_ModalidadIngreso = model.B_ModalidadIngreso,
                I_ModalidadIngresoID = model.I_ModalidadIngresoID,
                B_ConceptoAgrupa = model.B_ConceptoAgrupa,
                I_ConceptoAgrupaID = model.I_ConceptoAgrupaID,
                B_ConceptoAfecta = model.B_ConceptoAfecta,
                I_ConceptoAfectaID = model.I_ConceptoAfectaID,
                N_NroPagos = model.N_NroPagos,
                B_Porcentaje = model.B_Porcentaje,
                C_Moneda = model.C_Moneda == null ? "PEN" : model.C_Moneda,
                M_Monto = model.M_Monto,
                M_MontoMinimo = model.M_MontoMinimo,
                T_DescripcionLarga = model.T_DescripcionLarga,
                T_Documento = model.T_Documento,
                B_Habilitado = model.B_Habilitado,
                I_UsuarioCre = currentUserId,
                I_UsuarioMod = currentUserId
            };

            result = tasaService.Grabar_TasaUnfv(tasaEntity, saveOption, model.CtaDepositoID, model.servicioID);
        
            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(true);
            }

            return result;
        }

        public RegistrarTasaViewModel ObtenerTasaUnfv(int id)
        {
            var tasa = tasaService.ObtenerTasaUnfv(id);

            var result = new RegistrarTasaViewModel()
            {
                I_TasaUnfvID = tasa.I_TasaUnfvID,
                I_ConceptoID = tasa.I_ConceptoID,
                T_ConceptoPagoDesc = tasa.T_ConceptoPagoDesc,
                B_Fraccionable = tasa.B_Fraccionable ?? false,
                B_ConceptoGeneral = tasa.B_ConceptoGeneral ?? false,
                B_AgrupaConcepto = tasa.B_AgrupaConcepto ?? false,
                I_AlumnosDestino = tasa.I_AlumnosDestino,
                I_GradoDestino = tasa.I_GradoDestino,
                I_TipoObligacion = tasa.I_TipoObligacion,
                T_Clasificador = tasa.T_Clasificador,
                C_CodTasa = tasa.C_CodTasa,
                B_Calculado = tasa.B_Calculado ?? false,
                I_Calculado = tasa.I_Calculado,
                B_AnioPeriodo = tasa.B_AnioPeriodo ?? false,
                I_Anio = tasa.I_Anio,
                I_Periodo = tasa.I_Periodo,
                B_Especialidad = tasa.B_Especialidad ?? false,
                C_CodRc = tasa.C_CodRc,
                B_Dependencia = tasa.B_Dependencia ?? false,
                C_DepCod = tasa.C_DepCod,
                B_GrupoCodRc = tasa.B_GrupoCodRc ?? false,
                I_GrupoCodRc = tasa.I_GrupoCodRc,
                B_ModalidadIngreso = tasa.B_ModalidadIngreso ?? false,
                I_ModalidadIngresoID = tasa.I_ModalidadIngresoID,
                B_ConceptoAgrupa = tasa.B_ConceptoAgrupa ?? false,
                I_ConceptoAgrupaID = tasa.I_ConceptoAgrupaID,
                B_ConceptoAfecta = tasa.B_ConceptoAfecta ?? false,
                I_ConceptoAfectaID = tasa.I_ConceptoAfectaID,
                N_NroPagos = tasa.N_NroPagos,
                B_Porcentaje = tasa.B_Porcentaje ?? false,
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

        public Response ChangeState(int conceptoId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = tasaService.ChangeState(conceptoId, currentState, currentUserId);

            result.Redirect = returnUrl;

            return result;
        }

        public int[] ObtenerCtaDepositoIDs(int tasaUnfvID)
        {
            return tasaService.ObtenerCtaDepositoIDs(tasaUnfvID);
        }

        public int[] ObtenerServicioIDs(int tasaUnfvID)
        {
            return tasaService.ObtenerServicioIDs(tasaUnfvID);
        }
    }
}