using Domain.Helpers;
using Domain.Entities;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{
    public class CategoriaPagoModel
    {
        private readonly ICategoriaPago _categoriaPago;
        private readonly IEntidadRecaudadora _entidadFinanciera;
        private readonly ICuentaDeposito _cuentaDeposito;

        public CategoriaPagoModel()
        {
            _categoriaPago = new CategoriaPago();
            _entidadFinanciera = new EntidadRecaudadora();
            _cuentaDeposito = new CuentaDeposito();
        }

        public List<CategoriaPagoViewModel> Find()
        {
            var result = new List<CategoriaPagoViewModel>();

            foreach (var item in _categoriaPago.Find())
            {
                result.Add(new CategoriaPagoViewModel(item));
            }

            return result;
        }

        public List<CategoriaPagoViewModel> Find(TipoObligacion tipoObligacion)
        {
            var result = new List<CategoriaPagoViewModel>();

            foreach (var item in _categoriaPago.Find().Where(x => x.EsObligacion == (tipoObligacion == TipoObligacion.Matricula ? true : false)))
            {
                result.Add(new CategoriaPagoViewModel(item));
            }

            return result;
        }

        public CategoriaPagoRegistroViewModel Find(int categoriaPagoID)
        {
            CategoriaPago categoriaPago = _categoriaPago.Find(categoriaPagoID);
            var ctasBcoComercio = _cuentaDeposito.Find().Where(x => x.I_EntidadFinanId == Constantes.BANCO_COMERCIO_ID);

            var result = new CategoriaPagoRegistroViewModel(categoriaPago)
            {
                CtasBcoComercio = ctasBcoComercio.Select(x => x.I_CtaDepID).ToArray()
            };

            if (categoriaPago.CuentasDepositoEntidad.Where(x => x.EntidadFinanId == Constantes.BANCO_COMERCIO_ID).Count() > 0)
                result.MostrarCodBanco = true;

            return result;
        }

        public Response Save(CategoriaPagoRegistroViewModel model, int currentUserId)
        {
            CategoriaPago categoriaPago = new CategoriaPago()
            {
                CategoriaId = model.Id,
                Descripcion = model.Nombre,
                Nivel = model.NivelId,
                TipoAlumno = model.TipoAlumnoId,
                Prioridad = model.Prioridad,
                EsObligacion = model.EsObligacion,
                CodBcoComercio = model.CodBcoComercio,
                CuentasDeposito = model.CuentasDeposito.ToList()
            };

            Response result = _categoriaPago.Save(categoriaPago, currentUserId, (model.Id.HasValue ? SaveOption.Update : SaveOption.Insert));

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

        public Response ChangeState(int categoriaPagoID, bool currentState, int currentUserId, string returnUrl)
        {
            Response result = _categoriaPago.ChangeState(categoriaPagoID, currentState, currentUserId);
            result.Redirect = returnUrl;

            return result;
        }


        public ConceptoCategoriaPagoViewModel GetConceptosCategoria(int categoriaId)
        {
            var result = new ConceptoCategoriaPagoViewModel()
            {
                CategoriaId = categoriaId,
                Conceptos = _categoriaPago.GetConceptos(categoriaId).Select(x => new CatalogoConceptosViewModel(x)).ToList()
            };

            return result;
        }

        public Response CategoriaConceptosSave(ConceptoCategoriaPagoViewModel model, int currentUserId)
        {
            List<int> conceptosId = model.Conceptos.Select(x => x.Id.Value).ToList();

            Response result = _categoriaPago.ConceptosSave(model.CategoriaId.Value, conceptosId);

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
    }
}