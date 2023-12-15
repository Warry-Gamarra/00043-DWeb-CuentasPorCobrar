using Domain.Services.Implementations;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;
using Domain.Helpers;
using Domain.Entities;
using System.Web.Http.Results;

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

        public IEnumerable<SerieComprobanteModel> ListarSeriesComprobante()
        {
            var lista = _service.ListarSeriesComprobante(false);

            var result = lista.Select(x => new SerieComprobanteModel()
            {
                serieID = x.serieID,
                numeroSerie = x.numeroSerie,
                diasAnterioresPermitido = x.diasAnterioresPermitido,
                finNumeroComprobante = x.finNumeroComprobante,
                estaHabilitado  = x.estaHabilitado
            });

            return result;
        }

        public Response GrabarSerieComprobante(SerieComprobanteModel model, int userID)
        {
            Response response;
            SaveOption saveOption;

            try
            {
                saveOption = model.serieID.HasValue ? SaveOption.Update : SaveOption.Insert;

                var entity = new SerieComprobanteEntity()
                {
                    serieID = model.serieID,
                    diasAnterioresPermitido = model.diasAnterioresPermitido,
                    finNumeroComprobante = model.finNumeroComprobante,
                    numeroSerie = model.numeroSerie
                };

                response = _service.GrabarSerieComprobante(entity, saveOption, userID);
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            if (response.Value)
            {
                response.Success(false);
            }
            else
            {
                response.Error(true);
            }

            return response;
        }

        public Response ActualizarEstadoSerieComprobante(int serieComprobanteID, bool estaHabilitado, int userID, string returnUrl)
        {
            Response response;
            try
            {
                response = _service.ActualizarEstadoSerieComprobante(serieComprobanteID, estaHabilitado, userID);

                response.Redirect = returnUrl;
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }

        public Response EliminarEstadoSerieComprobante(int serieComprobanteID)
        {
            Response response;
            try
            {
                response = _service.EliminarEstadoSerieComprobante(serieComprobanteID);
            }
            catch (Exception ex)
            {
                response = new Response()
                {
                    Message = ex.Message
                };
            }

            return response;
        }
    }
}