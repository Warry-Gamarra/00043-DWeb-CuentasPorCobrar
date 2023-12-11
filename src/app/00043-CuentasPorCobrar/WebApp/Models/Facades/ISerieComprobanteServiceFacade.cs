using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface ISerieComprobanteServiceFacade
    {
        IEnumerable<SelectViewModel> ListarSeriesComprobante(bool soloHabilitados);
    }
}
