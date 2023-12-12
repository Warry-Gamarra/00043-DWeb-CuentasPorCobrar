using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class EstadoComprobanteServiceFacade : IEstadoComprobanteServiceFacade
    {
        private IEstadoComprobanteService _service;

        public EstadoComprobanteServiceFacade()
        {
            _service = new EstadoComprobanteService();
        }

        public IEnumerable<SelectViewModel> ListarEstadosComprobante(bool soloHabilitados)
        {
            var lista = _service.ListarEstadosComprobante(soloHabilitados);

            var result = lista.Select(x => new SelectViewModel()
            {
                Value = x.estadoComprobanteID.ToString(),
                TextDisplay = x.estadoComprobanteDesc.ToString()
            });

            return result;
        }
    }
}