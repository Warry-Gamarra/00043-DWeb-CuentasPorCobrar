using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class TipoComprobanteServiceFacade : ITipoComprobanteServiceFacade
    {
        private ITipoComprobanteService _service;

        public TipoComprobanteServiceFacade()
        {
            _service = new TipoComprobanteService();
        }

        public IEnumerable<SelectViewModel> ListarTiposComprobante(bool soloHabilitados)
        {
            var lista = _service.ListarTiposComprobante(soloHabilitados);

            var result = lista
                .OrderBy(x => x.tipoComprobanteDesc)
                .Select(x => new SelectViewModel() { 
                    Value = x.tipoComprobanteID.ToString(),
                    TextDisplay = x.tipoComprobanteDesc
                });

            return result;
        }
    }
}