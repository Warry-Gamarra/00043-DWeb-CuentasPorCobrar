using Domain.Services.Implementations;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class SerieComprobanteServiceFacade : ISerieComprobanteServiceFacade
    {
        private ISerieComprobanteService _service;

        public SerieComprobanteServiceFacade()
        {
            _service = new SerieComprobanteService();
        }

        public IEnumerable<SelectViewModel> ListarSeriesComprobante(bool soloHabilitados)
        {
            var lista = _service.ListarSeriesComprobante(soloHabilitados);

            var result = lista.Select(x => new SelectViewModel()
            {
                Value = x.serieID.ToString(),
                TextDisplay = x.numeroSerie.ToString()
            });

            return result;
        }
    }
}