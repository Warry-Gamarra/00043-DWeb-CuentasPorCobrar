using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebApp.Models;
using WebApp.ViewModels;

namespace WebApp.Controllers
{
    public class ServiceController : ApiController
    {
        private readonly ProcesoModel procesoModel;
        private readonly ConceptoPagoModel conceptoPagoModel;
        private readonly CategoriaPagoModel categoriaPagoModel;

        public ServiceController()
        {
            procesoModel = new ProcesoModel();
            conceptoPagoModel = new ConceptoPagoModel();
            categoriaPagoModel = new CategoriaPagoModel();
        }

        // GET: api/Service/5
        public int GetPrioridad(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }

            return procesoModel.Obtener_Prioridad_Tipo_Proceso(id);
        }

        // GET: api/Service/5
        public object GetDefaultValuesCategoria(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }
            string codBanco = categoriaPagoModel.Find(id).CodBcoComercio;
            List<SelectGroupViewModel> lista = procesoModel.Listar_Combo_CtaDepositoHabilitadas(id);
            
            return new { CodBanco = codBanco, CuentasDeposito = lista };
        }

        public CatalogoConceptosRegistroViewModel GetDefaultValuesConcepto(int id)
        {
            if (id == 0)
            {
                var error = new HttpResponseMessage(HttpStatusCode.NotAcceptable)
                {
                    Content = new StringContent("El ID proporcionado no puede ser 0.")
                };

                throw new HttpResponseException(error);
            }

            var model = conceptoPagoModel.ObtenerConcepto(id);

            return model;
        }

    }
}
