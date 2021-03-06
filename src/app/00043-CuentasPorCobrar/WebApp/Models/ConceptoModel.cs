﻿using Domain.Helpers;
using Domain.Entities;
using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class ConceptoModel
    {
        ConceptoPagoService conceptoPagoService;
        IProcesoService procesoService;
        readonly CategoriaPago categoriaPago;

        public ConceptoModel()
        {
            conceptoPagoService = new ConceptoPagoService();
            procesoService = new ProcesoService();
            categoriaPago = new CategoriaPago();
        }


        public Response ChangeState(int conceptoId, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = conceptoPagoService.ChangeState(conceptoId, currentState, currentUserId);
            result.Redirect = returnUrl;

            return result;
        }

        public Response Save(CatalogoConceptosRegistroViewModel model, int currentUserId)
        {
            ConceptoEntity concepto = new ConceptoEntity()
            {
                I_ConceptoID = model.Id ?? 0,
                T_ConceptoDesc = model.NombreConcepto,
                T_Clasificador = model.Clasificador,
                B_EsPagoMatricula = model.EsMatricula,
                B_EsPagoExtmp = model.Extemporaneo,
                B_ConceptoAgrupa = model.AgupaConceptos,
                I_Monto = model.Monto,
                I_MontoMinimo = model.MontoMinimo,
                B_Calculado = model.Calculado,
                I_Calculado = model.TipoCalculo,
                B_Mora = model.B_Mora
            };

            Response result = conceptoPagoService.Save(concepto, currentUserId, (model.Id.HasValue ? SaveOption.Update : SaveOption.Insert));

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

        public List<SelectViewModel> Listar_Combo_Concepto()
        {
            List<SelectViewModel> result = new List<SelectViewModel>();

            var lista = conceptoPagoService.Listar_Concepto_Habilitados();

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

        public List<CatalogoConceptosViewModel> Listar_CatalogoConceptos()
        {
            List<CatalogoConceptosViewModel> result = new List<CatalogoConceptosViewModel>();

            foreach (var item in conceptoPagoService.Listar_Concepto_All())
            {
                result.Add(new CatalogoConceptosViewModel(item));
            }

            return result;
        }

        public List<CatalogoConceptosViewModel> Listar_CatalogoConceptos(TipoObligacion tipoObligacion, bool conceptoAgrupa = false)
        {
            List<CatalogoConceptosViewModel> result = new List<CatalogoConceptosViewModel>();

            foreach (var item in conceptoPagoService.Listar_Concepto(tipoObligacion).Where(x => x.B_ConceptoAgrupa == conceptoAgrupa))
            {
                result.Add(new CatalogoConceptosViewModel(item));
            }

            return result;
        }

        public CatalogoConceptosRegistroViewModel ObtenerConcepto(int conceptoId)
        {
            var result = new CatalogoConceptosRegistroViewModel(conceptoPagoService.GetConcepto(conceptoId));

            return result;
        }
    }
}