using Domain.DTO;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class ConceptoPagoModel
    {
        ConceptoPagoService conceptoPagoService;
        PeriodoService periodoService;

        public ConceptoPagoModel()
        {
            conceptoPagoService = new ConceptoPagoService();
            periodoService = new PeriodoService();
        }

        public List<ConceptoPagoPeriodoViewModel> Listar_ConceptoPagoPeriodo_Habilitados()
        {
            List<ConceptoPagoPeriodoViewModel> result = new List<ConceptoPagoPeriodoViewModel>();

            var lista = conceptoPagoService.Listar_ConceptoPagoPeriodo_Habilitados();

            if (lista != null)
            {
                result = lista.Select(x => new ConceptoPagoPeriodoViewModel()
                {
                    I_ConcPagPerID = x.I_ConcPagPerID,
                    T_TipoPerDesc = x.T_TipoPerDesc,
                    T_ConceptoDesc = x.T_ConceptoDesc,
                    I_Anio = x.I_Anio,
                    I_Periodo = x.I_Periodo,
                    M_Monto = x.M_Monto
                }).ToList();
            }

            return result;
        }

        public List<SelectViewModel> Listar_Combo_ConceptoPago()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = conceptoPagoService.Listar_ConceptoPago_Habilitados();

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel()
                {
                    Value = x.I_ConceptoID.ToString(),
                    TextDisplay = x.T_ConceptoDesc
                }).ToList();
            }

            return result;
        }

        public List<SelectViewModel> Listar_Combo_CatalogoOpcion_X_Parametro(Domain.DTO.Parametro tipoParametroID)
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = conceptoPagoService.Listar_CatalogoOpcion_Habilitadas_X_Parametro(tipoParametroID);

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel()
                {
                    Value = x.I_OpcionID.ToString(),
                    TextDisplay = x.T_OpcionDesc
                }).ToList();
            }

            return result;
        }

        public List<SelectViewModel> Listar_Combo_CuotaPago()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = periodoService.Listar_Periodos_Habilitados();

            if (lista != null)
            {
                result = lista.Select(x => new SelectViewModel()
                {
                    Value = x.I_PeriodoID.ToString(),
                    TextDisplay = x.T_TipoPerDesc
                }).ToList();
            }

            return result;
        }

        public Response Grabar_ConceptoPagoPeriodo(MantenimientoConceptoPagoPeriodoViewModel model, int currentUserId)
        {
            ConceptoPagoPeriodoEntity conceptoPagoPeriodoEntity;
            
            var saveOption = (!model.I_ConcPagPerID.HasValue) ? SaveOption.Insert : SaveOption.Update;

            conceptoPagoPeriodoEntity = new ConceptoPagoPeriodoEntity()
            {
                I_ConcPagPerID = model.I_ConcPagPerID.GetValueOrDefault(),
                I_PeriodoID = model.I_PeriodoID,
                I_ConceptoID = model.I_ConceptoID,
                B_Fraccionable = model.B_Fraccionable,
                B_ConceptoGeneral = model.B_ConceptoGeneral,
                B_AgrupaConcepto = model.B_AgrupaConcepto,
                I_AlumnosDestino = model.I_AlumnosDestino,
                I_GradoDestino = model.I_GradoDestino,
                I_TipoObligacion = model.I_TipoObligacion,
                T_Clasificador = model.T_Clasificador,
                T_Clasificador5 = model.T_Clasificador5,
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
                M_Monto = model.M_Monto,
                M_MontoMinimo = model.M_MontoMinimo,
                T_DescripcionLarga = model.T_DescripcionLarga,
                T_Documento = model.T_Documento,
                B_Habilitado = model.B_Habilitado.HasValue ? model.B_Habilitado.GetValueOrDefault() : true,
                I_UsuarioCre = currentUserId,
                I_UsuarioMod = currentUserId
            };

            var result = conceptoPagoService.Grabar_ConceptoPagoPeriodo(conceptoPagoPeriodoEntity, saveOption);

            return result;
        }

        public MantenimientoConceptoPagoPeriodoViewModel Obtener_ConceptoPagoPeriodo(int I_ConcPagPerID)
        {
            var conceptoPago = conceptoPagoService.Obtener_ConceptoPagoPeriodo(I_ConcPagPerID);

            var model = new MantenimientoConceptoPagoPeriodoViewModel()
            {
                I_ConcPagPerID = conceptoPago.I_ConcPagPerID,
                I_PeriodoID = conceptoPago.I_PeriodoID,
                I_ConceptoID = conceptoPago.I_ConceptoID,
                B_Fraccionable = conceptoPago.B_Fraccionable.HasValue ? conceptoPago.B_Fraccionable.Value : false,
                B_ConceptoGeneral = conceptoPago.B_ConceptoGeneral.HasValue ? conceptoPago.B_ConceptoGeneral.Value : false,
                B_AgrupaConcepto = conceptoPago.B_AgrupaConcepto.HasValue ? conceptoPago.B_AgrupaConcepto.Value : false,
                I_AlumnosDestino = conceptoPago.I_AlumnosDestino,
                I_GradoDestino = conceptoPago.I_GradoDestino,
                I_TipoObligacion = conceptoPago.I_TipoObligacion,
                T_Clasificador = conceptoPago.T_Clasificador,
                T_Clasificador5 = conceptoPago.T_Clasificador5,
                B_Calculado = conceptoPago.B_Calculado.HasValue ? conceptoPago.B_Calculado.Value : false,
                I_Calculado = conceptoPago.I_Calculado,
                B_AnioPeriodo = conceptoPago.B_AnioPeriodo.HasValue ? conceptoPago.B_AnioPeriodo.Value : false,
                I_Anio = conceptoPago.I_Anio,
                I_Periodo = conceptoPago.I_Periodo,
                B_Especialidad = conceptoPago.B_Especialidad.HasValue ? conceptoPago.B_Especialidad.Value : false,
                C_CodRc = conceptoPago.C_CodRc,
                B_Dependencia = conceptoPago.B_Dependencia.HasValue ? conceptoPago.B_Dependencia.Value : false,
                C_DepCod = conceptoPago.C_DepCod,
                B_GrupoCodRc = conceptoPago.B_GrupoCodRc.HasValue ? conceptoPago.B_GrupoCodRc.Value : false,
                I_GrupoCodRc = conceptoPago.I_GrupoCodRc,
                B_ModalidadIngreso = conceptoPago.B_ModalidadIngreso.HasValue ? conceptoPago.B_ModalidadIngreso.Value : false,
                I_ModalidadIngresoID = conceptoPago.I_ModalidadIngresoID,
                B_ConceptoAgrupa = conceptoPago.B_ConceptoAgrupa.HasValue ? conceptoPago.B_ConceptoAgrupa.Value : false,
                I_ConceptoAgrupaID = conceptoPago.I_ConceptoAgrupaID,
                B_ConceptoAfecta = conceptoPago.B_ConceptoAfecta.HasValue ? conceptoPago.B_ConceptoAfecta.Value : false,
                I_ConceptoAfectaID = conceptoPago.I_ConceptoAfectaID,
                N_NroPagos = conceptoPago.N_NroPagos,
                B_Porcentaje = conceptoPago.B_Porcentaje.HasValue ? conceptoPago.B_Porcentaje.Value : false,
                M_Monto = conceptoPago.M_Monto,
                M_MontoMinimo = conceptoPago.M_MontoMinimo,
                T_DescripcionLarga = conceptoPago.T_DescripcionLarga,
                T_Documento = conceptoPago.T_Documento,
                B_Habilitado = conceptoPago.B_Habilitado
            };

            return model;
        }
    }
}